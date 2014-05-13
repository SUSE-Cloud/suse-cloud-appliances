# How do vendors approach High Availability?
Note: When we talk about the approach vendors take with providing high
availability for OpenStack, we really need to talk about 3 different
things:


## Deployment
Note: What does the vendor support/recommend to deploy OpenStack in
the first place?

(This is normally also their choice of deployment facility for an HA
manager, as everything else would be braindead.)


## HA Management
Note: Which high availability manager(s) does the vendor support for
ensuring service availability?


## State management
## Data availability
Note: What does the vendor support to ensure state sharing, or data
replication, between the backend stores of stateful services?


![Ubuntu logo](images/ubuntu-logo.svg)
Note: Ubuntu was probably the first distro vendor to put OpenStack HA
on the agenda.


### Juju deployment
### Pacemaker for HA management
### Ceph storage
Note: Ubuntu uses block storage (Ceph RBD) for all highly available
data.


![Cisco logo](images/cisco-logo.svg)
Note: Cisco is famous for saying "we won't use Pacemaker, it's way too
complicated" and then coming up with a solution whose documentation
would fill 57 pages when printed out on standard ISO A4 paper in
legible font.


### Puppet deployment
### HAProxy/keepalived
### Application-based replication
Note: Cisco makes no use of shared or replicated block storage at all;
all replication is within the application (includes MySQL/Galera).


![Piston logo](images/piston-logo.svg)
Note: Piston was among the first OpenStack vendors to recognize that
HA is important. However, you'll find that Piston is completely unlike
the other platforms discussed here, because...


### It's all Moxie magic!
Note: ... it doesn't really make use of a standard HA manager (or a
standard operating system, for that matter) at all. Instead, it uses a
secret sauce called
[Moxie Runtime Environment](http://www.pistoncloud.com/technology/moxie-runtime-environment/).


![Red Hat logo](images/redhat-logo.svg)
Note: Red Hat was a little late to the party (not just the HA party,
but the OpenStack party in general). It's only for Icehouse that they
finally went public with an HA solution.


### Puppet/Foreman deployment
### Pacemaker
### Galera


![SUSE logo](images/suse-logo.svg)


### Crowbar deployment
### Pacemaker/HAProxy
### Shared Storage/DRBD
