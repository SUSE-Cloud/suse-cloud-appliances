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
    if [ -z "$VAGRANT_KVM_USE_BUNDLER" ]; then
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
            esac

            unset VAGRANT_DEFAULT_PROVIDER
            ;;
        *)
            usage "Unrecognised hypervisor '$hypervisor'"
            ;;
    esac
}

vagrant_ssh_config () {
    vagrant ssh-config > $VAGRANT_SSH_CONFIG
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
