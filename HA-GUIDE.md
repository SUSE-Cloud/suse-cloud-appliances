# Automated Deployment of a Highly Available OpenStack Cloud

Attendee Instructions

## Prerequisites

If your system does not match these prerequisites, don’t worry!  You can still follow along on the main screen, or even better, share a laptop with a generous neighbour.  And the materials will all be provided so you can try again after you have gone home.

* Machine with >= 12GB RAM and 16GB spare disk

    * If you only have 8GB then you can probably manage to build an HA cluster for the control plane, but will not have space for a compute node in order to provision an instance.  This is still plenty interesting enough to be worth attempting!

* [VirtualBox](https://www.virtualbox.org/wiki/Downloads) >= 4.2 installed (4.3 recommended; older may work but untested)

    * configure one host-only network

* [Vagrant](http://www.vagrantup.com/) >= 1.5.x installed (1.6.2 recommended)

* Files (these will be provided if you arrive early!)

    * `cloud3-admin.ova`

    * `sles11-sp3.box`

    * `cirros-0.3.2-x86_64-disk.img`

    * [workshop git repository](https://github.com/aspiers/openstacksummit2014-atlanta.git) - this will be provided along with the files, but you can also get it directly from github via:

`git clone `[https://github.com/aspiers/openstacksummit2014-atlanta.git](https://github.com/aspiers/openstacksummit2014-atlanta.git)

## Preparation

Please feel free to start on this prior to the beginning of the workshop!

* Start VirtualBox’s GUI

* Import the `cloud3-admin.ova` virtual appliance into VirtualBox

* VirtualBox network preparation

    * *File* → *Preferences *→ *Network* then ensure you have:

        *  a single NAT network (in VirtualBox 4.2 this is hardcoded so don’t worry about it)

        * a host-only network, named `vboxnet0`, with IP `192.168.124.1` and **DHCP disabled**.

    * If you have other host-only networks, to be safe it seems you must delete them! (Sorry; as far as we can see this is a limitation of VirtualBox.)

* In the *Settings* of the appliance you imported, ensure that the **first** network interface is set to **NAT**, and the **second** network interface of the imported appliance is pointing to the **host-only** network.

* Boot the imported appliance.

* [http://192.168.124.10:3000/](http://localhost:3000/) should work as soon as the boot-up sequence completes. (This will take some time, since it has to start several services.)

* Import the SLES11 SP3 Vagrant box:

`cd openstacksummit2014-atlanta.git/vagrant/sles11-sp3`

`vagrant box add sles11-sp3.json`

* Use Vagrant to provision the other three VMs (which are vanilla SLES11 SP3):

`cd ..`

`vagrant up`

* This will also take some time, since on first boot the VMs will register against Crowbar and then perform some orchestrated setup via Chef.

* Please resist the temptation to make any changes in the Crowbar UI prior to the workshop, in case you miss a crucial detail and de-rail the whole thing!!

## Cloud installation

### Introduction

* Open the Crowbar UI at [http://192.168.124.10:3000](http://localhost:3000) (login: `crowbar`, password: `crowbar`)

* Check if all nodes are active in tab *Nodes* → *Dashboard* (they should be in green state)

* If using vagrant on Linux, run `./list-MACs.sh` to see the MAC addresses (which also forms the hostname) for each node.  Otherwise, just use the VirtualBox GUI to determine the MAC address of the second network interface on each node.

* In the Crowbar UI, go to tab *Nodes* → *Bulk Edit* and assign aliases **controller1**, **controller2** and **compute1** to the machines that have the MAC addresses found above.

<table>
  <tr>
    <td>N.B.! Leave the Public Name field blank! (since this would require extra upstream DNS records)</td>
  </tr>
</table>


### Deploy a Pacemaker cluster

* Go to tab *Barclamps* → *OpenStack* and click on *Edit* for *Pacemaker*

* Change proposal_1 to cluster1 and click *Create*

* Scroll down to *Deployment*, and drag the controller1 and controller2 nodes to both roles (**pacemaker-cluster- member **and **hawk-server**)

* Scroll back up and change the following options:

    * *STONITH* section:

        * Change* Configuration mode for STONITH* to **STONITH - Configured with STONITH Block Devices (SBD)**

        * enter **/dev/sdc** for both nodes under **Block devices for node**

    * *DRBD* section:

        * Change *Prepare cluster for DRBD* to **true** (controller1 and controller2 should have free disk to claim)

    * *Pacemaker GUI* section:

        * Change *Setup non-web GUI (hb_gui)* to **true**

* Click on *Apply* to deploy Pacemaker

<table>
  <tr>
    <td>Hint: You can follow the deployment by typing tail -f /var/log/crowbar/chef_client/* on the admin node.</td>
  </tr>
</table>


### Deploy Barclamps / OpenStack / Database

* Go to tab *Barclamps *→ *OpenStack *and click on *Create* for Database 

* Under *Deployment*, remove the node that is assigned to the **database-server** role, and drag **cluster1** to the **database-server** role

* Change the following options:

    * *High Availability* section:

        * Change *Storage mode* to **DRBD**

        * Change *Size to Allocate for DRBD Device* to **1**

* Click on *Apply* to deploy the database

### Deploy Barclamps / OpenStack / RabbitMQ

* Go to tab *Barclamps *→ *OpenStack *and click on *Create* for RabbitMQ 

* Under *Deployment*, remove the node that is assigned to the **rabbitmq-server** role, and drag **cluster1** to the **rabbitmq-server** role

* Change the following options:

    * *High Availability* section:

        * Change *Storage mode* to **DRBD**

        * Change *Size to Allocate for DRBD Device* to **1**

* Click on *Apply* to deploy RabbitMQ

### Deploy Barclamps / OpenStack / Keystone

* Go to tab *Barclamps *→ *OpenStack *and click on *Create* for Keystone 

* Do not change any option

* Under *Deployment*, remove the node that is assigned to the **keystone-server** role, and drag **cluster1** to the **keystone-server** role

* Click on *Apply* to deploy Keystone

### Deploy Barclamps / OpenStack / Glance

<table>
  <tr>
    <td>N.B.! To simplify the HA setup of Glance for the workshop, a NFS export has been automatically setup on the admin node, and mounted on /var/lib/glance on both controller nodes. Reliable shared storage is highly recommended for production; also note that alternatives exist (for instance, using the swift or ceph backends).</td>
  </tr>
</table>


* Go to tab *Barclamps *→ *OpenStack *and click on *Create* for Glance

* Do not change any option

* Under *Deployment*, remove the node that is assigned to the **glance-server** role, and drag **cluster1** to the **glance-server** role

* Click on *Apply* to deploy Glance

### Deploy Barclamps / OpenStack / Cinder

<table>
  <tr>
    <td>N.B.! The cinder volumes will be stored on the compute node. The controller nodes are not used to allow easy testing of failover. On a real setup, using a SAN to store the volumes would be recommended.</td>
  </tr>
</table>


* Go to tab *Barclamps *→ *OpenStack *and click on *Create* for Cinder

* Change the following options:

    * Change *Type of Volume* to **Local file**

* Under *Deployment*, remove the node that is assigned to the **cinder-controller** role, and drag **cluster1** to the **cinder-controller** role

* Under *Deployment*, remove the node that is assigned to the **cinder-volume** role, and drag **compute1** to the **cinder-volume** role

* Click on *Apply* to deploy Cinder

### Deploy Barclamps / OpenStack / Neutron

* Go to tab *Barclamps *→ *OpenStack *and click on *Create* for Neutron

* Do not change any option

* Under *Deployment*, remove the node that is assigned to the **neutron-server** role, and drag **cluster1** to the **neutron-server **role

* remove the node that is assigned to the **neutron-l3** role, and drag and drop **cluster1** to **neutron-l3 **role

* Click on *Apply* to deploy Neutron

### Deploy Barclamps / OpenStack / Nova

* Go to tab *Barclamps *→ *OpenStack *and click on *Create* for Nova

* Do not change any option

* Under *Deployment*:

    * remove all nodes which are assigned to roles such as **nova-multi-controller** and **nova-multi-compute-xen**

    * drag **cluster1** to the **nova-multi-controller **role

    * drag **compute1** to the **nova-multi-compute-qemu **role

* Click on *Apply* to deploy Nova

### Deploy Barclamps / OpenStack / Horizon

* Go to tab *Barclamps *→ *OpenStack *and click on *Create* for Horizon

* Do not change any option

* Under *Deployment*, remove the node that is assigned to the **nova_dashboard-server** role, and drag **cluster1** to the **nova_dashboard-server **role

* Click on *Apply* to deploy Horizon

## Playing with Cloud 

### Introduction

* To log into the OpenStack Dashboard (Horizon):

    * In the Crowbar web UI, click on *Nodes* 

    * Click on `controller1`

    * Click on the **OpenStack Dashboard (admin)** link

    * login: `admin`, password: `crowbar`

* Choose the `Project` tab and for *Current Project* select `openstack`

### Upload image

* Go to Images & Snapshots from Manage Compute section

* Click on **Create Image** button and provide the following data:

    * *Name* - image name

    * *Image Source* - Image File

    * *Image File* - click on Browse button to choose image file

    * Format - QCOW2 - QEMU Emulator

    * Minimum Disk GB - 0 (no minimum)

    * Minimum RAM MB - 0 (no minimum)

    * Public - check this option

    * Protected - leave unchecked

* Click on **Create Image** button to proceed and upload image

### Launching VM instance

* Go to Instances from Manage Compute section

* Click on Launch Instance button

* In the *Details* tab set up

    * Availability Zone - nova

    * Instance Name - name of new VM

    * Flavor - `m1.tiny`

    * Instance Count - 1

    * Instance Boot Source - Boot from image

    * Image Name - choose uploaded image file

* in Networking tab set up

    * drag and drop fixed network from Available Networks to Selected Networks

* click on Launch button and wait until new VM instance will be ready

## Playing with High-Availability

### Introduction

* open console to controller1, controller2 and compute1 nodes and login there

* on controller1 and controller2 run crm_mon command

* on controller1 run 

    * `. .openrc`

    * `nova service-list`

    * `nova list`

### Failover scenarios for services

* on controller1 or controller2 try to kill OpenStack services using command

    * pkill openstack-keystone

    * pkill openstack-glance

    * pkill openstack-nova

* watch on consoles with crm_mon how all services are bringing up by pacemaker 

### Failover scenarios for nodes

* on controller1 run crm_mon command

* kill controller2 node

    * halt or shutdown -h now

* watch on consoles with crm_mon how all services are bringing up by pacemaker 

