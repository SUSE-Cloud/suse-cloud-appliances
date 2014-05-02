# This builds a vagrant box with a very similar end result to "vagrant
# package", except the .ovf file is taken from this git repository,
# and the .vmdk is taken from the kiwi build.

BOX_NAME   = cloud3-admin

BOX_FILE   = $(BOX_NAME).box
VMDK       = box-disk1.vmdk
OVF        = box.ovf

COMPONENTS = Vagrantfile metadata.json $(VMDK) $(OVF)

KIWI_IMAGE_DIR = ../../kiwi/image

default: $(BOX_FILE)

$(VMDK): $(wildcard $(KIWI_IMAGE_DIR)/*.vmdk)
	@latest=$$( ls -t $(KIWI_IMAGE_DIR)/*.vmdk | head -n1 ); \
	echo "latest vmdk is $$latest"; \
	cp -iv "$$latest" $@

$(BOX_FILE): $(COMPONENTS)
	tar cvf $@ $(COMPONENTS)
