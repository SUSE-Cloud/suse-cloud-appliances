# Testing high availability


### Retrieve
# Horizon URL
### from Crowbar

OpenStack Dashboard (admin)

`admin`/`crowbar`


### Select
# `openstack`
### Project
(a.k.a tenant)


### Use as you normally would


### Doing
# bad things
### to services


`pkill openstack-keystone`

`pkill openstack-glance`


### Watch
# services
### recover automatically
`crm_mon`


### Doing
# bad things
### to nodes


`poweroff -f`

`echo o > /proc/sysrq-trigger`


### Watch
# services
### fail over automatically
`crm_mon`
