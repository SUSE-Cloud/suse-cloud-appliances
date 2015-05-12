#!/bin/bash

set -e

DEMO_PROJECT=Wordpress
DEMO_USER=suseuser
DEMO_PASSWORD=$DEMO_USER # security is our top priority
MYSQL_IMAGE_FILE=MySQL.x86_64-0.0.3.qcow2
WORDPRESS_IMAGE_FILE=Wordpress.x86_64-0.0.8.qcow2
MYSQL_IMAGE_NAME=MySQL-0.0.3-kvm
WORDPRESS_IMAGE_NAME=Wordpress-0.0.8-kvm

source ~/.openrc

# FIXME: would be nicer to use Chef for all this.

exists () {
    object="$1" name="$2"
    shift 2
    if ! list=$( openstack $object list "$@" -c Name -f csv ); then
        echo "openstack $object list failed; aborting" >&2
        exit 1
    fi
    if echo "$list" | grep -q "^\"${name}\""; then
        echo "'$name' $object already exists"
        return 0
    else
        return $?
    fi
}

if ! exists project $DEMO_PROJECT; then
    echo "Creating $DEMO_PROJECT project ..."
    openstack project create $DEMO_PROJECT
fi

if ! exists user $DEMO_USER; then
    echo "Creating $DEMO_USER user ..."
    openstack user create $DEMO_USER --password $DEMO_USER --project $DEMO_PROJECT
fi

# User already has _member_ role from --project above
for role in admin; do
    if ! exists 'user role' $role --project $DEMO_PROJECT $DEMO_USER; then
        echo "Giving $DEMO_USER $role role in $DEMO_PROJECT project ..."
        # Cloud 4's new openstack CLI didn't support adding roles to users:
        #openstack user role add $role --user $DEMO_USER --project $DEMO_PROJECT
        # FIXME: worth revisiting with Cloud 5
        keystone user-role-add --user $DEMO_USER --role $role --tenant $DEMO_PROJECT
    fi
done

export OS_USERNAME="$DEMO_USER"
export OS_PASSWORD="$DEMO_PASSWORD"
export OS_TENANT_NAME="$DEMO_PROJECT"

ensure_tcp_rule () {
    group="$1" dst_port="$2"
    if openstack security group rule list $group -f csv |
        grep -q '"tcp","0.0.0.0/0",'"\"$dst_port:$dst_port\""; then
    #if nova secgroup-list-rules $group | egrep -q " tcp +\| +\|  $group "; then
        echo "TCP port $dst_port already allowed for $group"
    else
        echo "Allowing TCP port $dst_port for $group ..."
        openstack security group rule create --proto tcp --dst-port $dst_port $group
        #nova secgroup-add-rule $group 
    fi
}

for group in MySQLSecGroup WWWSecGroup; do
    if ! exists 'security group' $group; then
        echo "Creating security group $group ..."
        openstack security group create $group
    fi

    if openstack security group rule list $group -f csv | grep -q '"icmp"'; then
    #if nova secgroup-list-rules $group | grep -q " icmp .* | $group "; then
        echo "ICMP already allowed for $group"
    else
        echo "Allowing ICMP for $group ..."
        openstack security group rule create --proto icmp --dst-port -1 $group
    fi

    ensure_tcp_rule $group 22
done

ensure_tcp_rule MySQLSecGroup 3306
ensure_tcp_rule WWWSecGroup     80

# Need to get security group ids to substitute into heat template.
# Wanted to do:
#
#   eval `openstack security group show $group -f shell --variable id`
#
# but it fails (only) for default group - bizarre.  So we take a
# different approach:

eval $(
    openstack security group list -f csv -c ID -c Name | grep -v '^"ID"' | \
        sed 's/^"\(.\+\)","\(.\+\)".*/\2_id=\1/'
)

network_id () {
    network="$1"
    eval `neutron net-show $network -f shell -F id`
    echo "$id"
}

fixed_network_id=`network_id fixed`
floating_network_id=`network_id floating`

echo "Writing heat-template-wordpress.json from template ..."
sed "s/@@DefaultSecGroupId@@/$default_id/;
     s/@@WWWSecGroupId@@/$WWWSecGroup_id/;
     s/@@MySQLSecGroupId@@/$MySQLSecGroup_id/;

     s/@@FloatingNetworkId@@/$floating_network_id/;
     s/@@FixedNetworkId@@/$fixed_network_id/;
    " heat-template-wordpress.json.tmpl \
    > heat-template-wordpress.json

if ! exists image $MYSQL_IMAGE_NAME; then
    echo "Uploading $MYSQL_IMAGE_FILE as $MYSQL_IMAGE_NAME ..."
    openstack image create \
        --file $MYSQL_IMAGE_FILE \
        --owner $DEMO_PROJECT \
        $MYSQL_IMAGE_NAME
fi

if ! exists image $WORDPRESS_IMAGE_NAME; then
    echo "Uploading $WORDPRESS_IMAGE_FILE as $WORDPRESS_IMAGE_NAME ..."
    openstack image create \
        --file $WORDPRESS_IMAGE_FILE \
        --owner $DEMO_PROJECT \
        $WORDPRESS_IMAGE_NAME
fi

if ! exists keypair $DEMO_USER; then
    openstack keypair create $DEMO_USER > $DEMO_USER.pem
fi
