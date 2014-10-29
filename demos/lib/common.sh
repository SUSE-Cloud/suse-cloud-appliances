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

init_bundler () {
    if [ -z "$VAGRANT_USE_BUNDLER" ]; then
        return
    fi

    if ! which bundle >/dev/null 2>&1; then
        die "Bundler is required!  Please install first."
    fi

    cd $vagrant_dir
    if ! bundle install --path vendor/bundle; then
        die "bundle install failed; cannot proceed"
    fi
}

check_hypervisor () {
    case "$hypervisor" in
        kvm)
            if ! grep -q Y /sys/module/kvm_intel/parameters/nested; then
                die "Your host's kvm_intel kernel module needs the nested parameter enabled".
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

            export VAGRANT_DEFAULT_PROVIDER=libvirt
            ;;
        virtualbox)
            version=$( VirtualBox --help | head -n1 | awk '{print $NF}' )
            case "$version" in
                4.[012].*)
                    die "Please upgrade to the most recent VirtualBox"
                    ;;
                4.3.[0-9])
                    echo "WARNING: Your VirtualBox is old-ish.  Please consider upgrading." >&2
                    ;;
            esac

            if [ "`uname -s`" = Linux ]; then
                if ! groups | grep -q vboxusers; then
                    die "The current user does not have access to the 'vboxusers' group.  This is necessary for VirtualBox to function correctly."
                fi

                if which lsmod >/dev/null 2>&1; then
                    if ! lsmod | grep -q vboxdrv; then
                        die "Your system doesn't have the vboxdrv kernel module loaded.  This is necessary for VirtualBox to function correctly."
                    fi
                else
                    fatal "BUG: Linux but no lsmod found?!  Huh?"
                fi
            fi

            export VAGRANT_DEFAULT_PROVIDER=virtualbox
            ;;
        *)
            usage "Unrecognised hypervisor '$hypervisor'"
            ;;
    esac
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
