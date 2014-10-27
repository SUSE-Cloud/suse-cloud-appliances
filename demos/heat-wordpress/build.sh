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

    check_hypervisor

    export VAGRANT_CONFIG_FILE=$vagrant_dir/configs/1-controller-1-compute.yaml

    if ! vagrant up --no-parallel; then
        die "vagrant up failed; aborting"
    fi

    vagrant_ssh_config

    if ! vssh admin sudo /root/bin/setup-node-aliases.sh; then
        die "Failed to set up node aliases; aborting"
    fi

    if [ $hypervisor != kvm ]; then
        echo "Can't do nested hardware virtualization; switching to QEMU ..."
        if ! vssh admin sudo sed -i \
            's/nova-multi-compute-.*:/nova-multi-compute-qemu:/' \
            /root/simple-cloud.yaml; then
            die "Failed to switch simple-cloud.yaml to use QEMU"
        fi
    fi

    if ! vssh admin sudo stdbuf -oL \
        crowbar batch --timeout 900 build /root/simple-cloud.yaml
    then
        die "Failed to set up proposals; aborting"
    fi

    cd $here
    echo "Downloading appliances to $here ..."
    wget -c https://www.dropbox.com/s/7334ic3d86aypsq/MySQL.x86_64-0.0.3.qcow2
    wget -c https://www.dropbox.com/s/xtsk9lbcqludu72/Wordpress.x86_64-0.0.8.qcow2

    echo "Copying appliances to controller1 ..."
    vrsync -avLP \
        *.qcow2 prep-wordpress-project.sh \
        heat-template-wordpress.json.tmpl \
        controller1:

    echo "Preparing Wordpress project in OpenStack cloud ..."
    if ! vssh controller1 sudo ./prep-wordpress-project.sh; then
        die "Failed to prepare Wordpress project in OpenStack; aborting"
    fi

    for f in heat-template-wordpress.json suseuser.pem; do
        if ! vscp controller1:$f .; then
            die "Failed to scp $f back to host; aborting"
        fi
    done

    cat <<'EOF'

Success!

The Wordpress project has been prepared.  You can now create and
launch a new Wordpress stack using the heat-template-wordpress.json
file in this directory.
EOF
}

main "$@"
