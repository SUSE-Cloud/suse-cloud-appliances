KIWI_IMAGE_DIR = ../../kiwi/$(BOX_NAME)/image

BOX_FILE   = $(BOX_NAME).box
BOX_VMDK   = box-disk1.vmdk
OVF        = box.ovf

COMPONENTS = Vagrantfile metadata.json $(OVF) $(KIWI_IMAGE_DIR)/$(VMDK)

default: $(BOX_FILE)

$(BOX_FILE): $(COMPONENTS)
	tar --transform="s,.*\.vmdk,$(BOX_VMDK)," -cvf $@ $(COMPONENTS)
