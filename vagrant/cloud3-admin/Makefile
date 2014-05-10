# This builds a vagrant box with a very similar end result to "vagrant
# package", except the .ovf file is taken from this git repository,
# and the .vmdk is taken from the kiwi build.

BOX_NAME   = cloud3-admin

KIWI_IMAGE_DIR = ../../kiwi/$(BOX_NAME)/image
VMDK = SLES_11_SP3_ReOS_for_OpenStack_summit_2014.x86_64-0.0.1.vmdk

BOX_FILE   = $(BOX_NAME).box
BOX_VMDK   = box-disk1.vmdk
OVF        = box.ovf

COMPONENTS = Vagrantfile metadata.json $(OVF) $(KIWI_IMAGE_DIR)/$(VMDK)

default: $(BOX_FILE)

$(BOX_FILE): $(COMPONENTS)
	@tar --transform="s,.*\.vmdk,$(BOX_VMDK)," -cvf $@ $(COMPONENTS)
