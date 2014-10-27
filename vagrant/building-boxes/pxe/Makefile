SIZE  = 16
NAME  = pxe-$(SIZE)GB
QCOW2 = $(NAME).qcow2
VMDK  = $(NAME).vmdk
LIBVIRT_BOX_FILE      = $(NAME)-libvirt.box
VIRTUALBOX_BOX_FILE   = $(NAME)-virtualbox.box
COMMON_COMPONENTS     = Vagrantfile
LIBVIRT_COMPONENTS    = $(COMMON_COMPONENTS) $(QCOW2) metadata-libvirt.json
VIRTUALBOX_COMPONENTS = $(COMMON_COMPONENTS) $(VMDK)  metadata-virtualbox.json

default: $(LIBVIRT_BOX_FILE)

$(QCOW2):
	qemu-img create -f qcow2 $@ $(SIZE)G

$(LIBVIRT_BOX_FILE): $(LIBVIRT_COMPONENTS) Makefile
	tar -jhcvf $@ \
		 --transform="s,metadata-libvirt,metadata," \
		$(LIBVIRT_COMPONENTS)
	@echo Created $@

$(VIRTUALBOX_BOX_FILE): $(VIRTUALBOX_COMPONENTS) Makefile
	tar -jhcvf $@ \
		--transform="s,metadata-virtualbox,metadata,;
			     s,.*\.vmdk,$(BOX_VMDK)," \
		$(VIRTUALBOX_COMPONENTS)
	@echo Created $@
