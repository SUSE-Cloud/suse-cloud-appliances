#!/bin/bash

here=$(cd `dirname $0` && pwd)
source $here/../lib/common.sh
vagrant_dir=$(cd $here/../../vagrant && pwd)

usage () {
    # Call as: usage [EXITCODE] [USAGE MESSAGE]
    exit_code=1
    if [[ "$1" == [0-9] ]]; then
        exit_code="$1"
        shift
    fi
    if [ -n "$1" ]; then
        echo >&2 "$*"
        echo
    fi

    me=`basename $0`

    cat <<EOF >&2
Usage: $me [options] HYPERVISOR
Options:
  -h, --help     Show this help and exit

Hypervisor can be 'kvm' or 'virtualbox'.
EOF
    exit "$exit_code"
}

parse_args () {
    if [ ${#ARGV[@]} != 1 ]; then
        usage
    fi

    hypervisor="${ARGV[0]}"
}

main () {
    parse_opts "$@"
    parse_args

    if [ $hypervisor = kvm ]; then
        # Required so vagrant-libvirt can deal with shared disks.
        export VAGRANT_USE_BUNDLER=yes
        init_bundler
    fi

    check_hypervisor

    if ! vagrant up --no-parallel; then
        die "vagrant up failed; aborting"
    fi

    vagrant_ssh_config

    setup_node_aliases
    setup_node_sh_vars

    if [ $hypervisor != kvm ]; then
        echo "Can't do nested hardware virtualization; switching to QEMU ..."
        if ! vssh admin sudo sed -i \
            's/nova-multi-compute-.*:/nova-multi-compute-qemu:/' \
            /root/simple-cloud.yaml; then
            die "Failed to switch simple-cloud.yaml to use QEMU"
        fi
    fi

    if ! vssh admin sudo stdbuf -oL \
        crowbar batch --timeout 900 build /root/HA-cloud.yaml
    then
        die "Failed to set up proposals; aborting"
    fi

    cat <<'EOF'

Success!

A highly-available OpenStack cloud has been built.  You can now test failover.
EOF
}

main "$@"
