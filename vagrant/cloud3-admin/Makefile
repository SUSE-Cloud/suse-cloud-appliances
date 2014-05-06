# This builds a vagrant box with a very similar end result to "vagrant
# package", except the .ovf file is taken from this git repository,
# and the .vmdk is taken from the kiwi build.

BOX_NAME   = cloud3-admin

BOX_FILE   = $(BOX_NAME).box
VMDK       = box-disk1.vmdk
OVF        = box.ovf

COMPONENTS = Vagrantfile metadata.json $(OVF)

KIWI_IMAGE_DIR = ../../kiwi/$(BOX_NAME)/image

default: $(BOX_FILE)

$(BOX_FILE): $(COMPONENTS)
	@latest=$$( ls -t $(KIWI_IMAGE_DIR)/*.vmdk | head -n1 ); \
	echo "latest vmdk is $$latest"; \
	tar --transform="s,.*\.vmdk,$(VMDK)," -cvf $@ $(COMPONENTS) "$$latest"
