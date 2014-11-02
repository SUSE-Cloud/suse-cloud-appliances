#!/bin/bash

VAGRANT_SSH_CONFIG=/tmp/ssh-config.vagrant

die () {
    echo >&2 "$*"
    exit 1
}

parse_opts () {
    while [ $# != 0 ]; do
        case "$1" in
            -h|--help)
                usage 0
                ;;
            -*)
                usage "Unrecognised option: $1"
                ;;
            *)
                break
                ;;
        esac
    done

    ARGV=( "$@" )
}

vagrant () {
    cd $vagrant_dir

    if [ -n "$VAGRANT_USE_BUNDLER" ]; then
        VAGRANT_I_KNOW_WHAT_IM_DOING_PLEASE_BE_QUIET=1 \
            bundle exec vagrant "$@"
    else
        command vagrant "$@"
    fi
}

read_libvirt_docs () {
    cat <<EOF >&2

Make sure you have read docs/vagrant-libvirt.md, which is available
online here:

  https://github.com/SUSE-Cloud/suse-cloud-vagrant/blob/master/docs/vagrant-libvirt.md
EOF
    exit 1
}

init_bundler () {
    if [ -z "$VAGRANT_USE_BUNDLER" ]; then
        return
    fi

    if ! which bundle >/dev/null 2>&1; then
        echo "Bundler is required!  Please install first." >&2
        read_libvirt_docs
    fi

    cd $vagrant_dir
    if ! bundle inkstall --path vendor/bundle; then
        echo "bundle install failed; cannot proceed." >&2
        read_libvirt_docs
    fi
}

check_hypervisor () {
    case "$hypervisor" in
        kvm)
            check_nested_kvm
            check_ksm
            export VAGRANT_DEFAULT_PROVIDER=libvirt
            ;;
        virtualbox)
            check_virtualbox_version
            check_virtualbox_env
            export VAGRANT_DEFAULT_PROVIDER=virtualbox
            ;;
        *)
            usage "Unrecognised hypervisor '$hypervisor'"
            ;;
    esac
}

on_linux () {
    [ "`uname -s`" = Linux ]
}

check_nested_kvm () {
    if ! on_linux; then
        return
    fi

    if grep -q Intel /proc/cpuinfo; then
        cpu=intel
    elif grep -q AMD /proc/cpuinfo; then
        cpu=amd
    else
        echo "WARNING: couldn't detect either Intel or AMD CPU; skipping nested KVM check" >&2
        return
    fi

    kmod=kvm-$cpu
    nested=/sys/module/kvm_$cpu/parameters/nested
    if ! [ -e $nested ]; then
        cat <<EOF >&2
Your host's kvm_$cpu kernel module is not loaded!

Make sure its nested parameter is enabled and then load it, e.g. by
running these commands:

    # Needs root access, so su or sudo first!
    echo "options $kmod nested=1" > /etc/modprobe.d/90-nested-kvm.conf

    # Load the kernel module
    modprobe $kmod

Then re-run this script.
EOF
        exit 1
    fi

    if ! grep -q Y $nested; then
        cat <<EOF >&2
Your host's kvm_$cpu kernel module needs the nested parameter enabled.
To enable it, run these commands:

    # Needs root access, so su or sudo first!
    echo "options $kmod nested=1" > /etc/modprobe.d/90-nested-kvm.conf
    # Reload the kernel module (shutdown any running VMs first):
    rmmod $kmod
    modprobe $kmod

Then re-run this script.
EOF
        exit 1
    fi
}

check_ksm () {
    if ! on_linux; then
        return
    fi

    if ! grep -q 1 /sys/kernel/mm/ksm/run; then
        cat <<'EOF'
You don't have Kernel SamePage Merging (KSM) enabled!
This could reduce your memory usage quite a bit.
To enable it, hit Control-C and then run this command as
root:

    echo 1 > /sys/kernel/mm/ksm/run

Alternatively, press Enter to proceed regardless ...
EOF
        read
    fi
}

check_virtualbox_version () {
    if ! version=$( VBoxManage --help | head -n1 | awk '{print $NF}' ); then
        echo "WARNING: Couldn't determine VirtualBox version; carrying on anyway." >&2
        return
    fi

    case "$version" in
        [1-3].*|4.[012].*)
            die "Your VirtualBox is old ($version); please upgrade to the most recent version!"
            ;;
        4.3.[0-9])
            echo "WARNING: Your VirtualBox is old-ish.  Please consider upgrading." >&2
            ;;
        [4-9].*)
            # New enough!
            ;;
        *)
            die "Unrecognised VirtualBox version '$version'"
            ;;
    esac
}

check_virtualbox_env () {
    if ! on_linux; then
        return
    fi

    if ! groups | grep -q vboxusers; then
        die "The current user does not have access to the 'vboxusers' group.  This is necessary for VirtualBox to function correctly."
    fi

    if ! which lsmod >/dev/null 2>&1; then
        die "BUG: on Linux but no lsmod found?!  Huh?"
    fi

    if ! lsmod | grep -q vboxdrv; then
        die "Your system doesn't have the vboxdrv kernel module loaded.  This is necessary for VirtualBox to function correctly."
    fi
}

check_vagrant_config () {
    cd $vagrant_dir
    if [ -n "$VAGRANT_CONFIG_FILE" ]; then
        if [ ! -e "$VAGRANT_CONFIG_FILE" ]; then
            echo "VAGRANT_CONFIG_FILE points to non-existent file $VAGRANT_CONFIG_FILE" >&2
            die "It should be an absolute path or relative to $vagrant_dir."
        fi
        if ! grep -q '^vms: *$' "$VAGRANT_CONFIG_FILE"; then
            die "$VAGRANT_CONFIG_FILE is not a valid config for Vagrantfile"
        fi
    fi
}

vagrant_ssh_config () {
    vagrant ssh-config > $VAGRANT_SSH_CONFIG
}

setup_node_aliases () {
    if ! vssh admin sudo /root/bin/setup-node-aliases.sh; then
        die "Failed to set up node aliases; aborting"
    fi
}

setup_node_sh_vars () {
    if vssh admin sudo \
        sh -c '/root/bin/node-sh-vars > /tmp/.crowbar-nodes-roles.cache'
    then
        echo "Wrote node/role shell variables to /tmp/.crowbar-nodes-roles.cache"
    else
        die "Failed to set up node shell variables; aborting"
    fi
}

switch_to_kvm_if_required () {
    if [ $hypervisor != kvm ]; then
        return
    fi

    echo "Can do nested hardware virtualization; switching to KVM ..."
    # I tried and failed to do this with a glob and a single call to
    # sudo - saw some inexplicable interaction between ssh/sudo/sh.
    # If anyone can show me how I'd be grateful!
    if ! vssh admin \
        'sudo find /root -maxdepth 1 -name *.yaml |
         xargs sudo sed -i \
             "s/nova-multi-compute-.*:/nova-multi-compute-kvm:/"'
    then
        die "Failed to switch YAML files to use KVM"
    fi
}

batch_build_proposals () {
    yaml="$1"

    if ! vssh admin sudo stdbuf -oL \
        crowbar batch --timeout 1200 build $yaml
    then
        die "Failed to set up proposals; aborting"
    fi
}

vssh () {
    ssh -F $VAGRANT_SSH_CONFIG "$@"
}

vscp () {
    scp -F $VAGRANT_SSH_CONFIG "$@"
}

vrsync () {
    rsync -e "ssh -F $VAGRANT_SSH_CONFIG" "$@"
}
