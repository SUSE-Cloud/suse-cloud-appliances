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

    case "$hypervisor" in
        kvm)
            VAGRANT_I_KNOW_WHAT_IM_DOING_PLEASE_BE_QUIET=1 \
                bundle exec vagrant "$@"
            ;;
        virtualbox)
            command vagrant "$@"
            ;;
        '')
            die "BUG: \$hypervisor not set"
            ;;
        *)
            die "Unsupported hypervisor '$hypervisor'"
            ;;
    esac
}

check_hypervisor () {
    case "$hypervisor" in
        kvm)
            if ! grep -q Y /sys/module/kvm_intel/parameters/nested; then
                die "Your host's kvm_intel kernel module needs the nested parameter enabled".
            fi

            # This is only needed for HA setups.
            cd $vagrant_dir
            if ! bundle install; then
                die "vagrant-libvirt needs patches for extra disks"
            fi
            ;;
        virtualbox)
            version=$( VirtualBox --help | head -n1 | awk '{print $NF}' )
            case "$version" in
                4.[012].*)
                    die "Please upgrade to the most recent VirtualBox"
            esac
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
