# iso2repo
# host any iso with httpd

# configuration
export ISO_DIR		  	:= ./isos
export REPOS_DIR	  	:= ./repos
export REPOS_IPADDR   	:= localhost
export REPOS_PORT     	:= 8080

.PHONY: help

help:
	@echo "Usage: make <target>"
	@echo "Targets:"
	@echo "  all              - Mount isos, create repo, host http"
	@echo "  create-repos     - Create repo for $(REPOS_DIR)"
	@echo "  mount-isos       - Mount iso files to $(REPOS_DIR)"
	@echo "  unmount-isos     - Unmount iso files from $(REPOS_DIR)"

all: mount-isos create-repos httpd

create-repos:
	@ which createrepo ; if [ $$? != 0 ] ; then \
		echo "Install createrepo!"; \
	else \
	   createrepo $(REPOS_DIR) ; \
	fi

httpd:
	@ python http_server.py ;

mount-isos:
	@ whichiso() { \
		basename "$$1" .iso ; \
	}; \
	if uname -r | grep -qiE 'wsl|microsoft|windows' ; then \
	  echo -e "Mounting ISOs"; \
	  for iso in $$( ls $(ISO_DIR)/*.iso ); do \
	    mountpoint=$(REPOS_DIR)/$$(whichiso "$$iso"); \
	    mkdir -p "$$mountpoint"; \
	    echo "Checking $$mountpoint repo..."; \
	    if [[ ! $$(ls -A "$$mountpoint") ]]; then \
	      echo "Mounting ISO: $$iso"; \
	      sudo losetup -fP "$$iso"; \
	      loopdev=$$(losetup | grep "$$iso" | awk '{ print $$1 }'); \
	      sudo mount $$loopdev "$$mountpoint"; \
	    fi; \
	  done; \
	else \
	  echo -e "Mounting ISOs"; \
	  for iso in $(ISO_DIR)/*.iso; do \
	    mountpoint=$(REPOS_DIR)/$$(whichiso "$$iso"); \
	    echo "Mounting $$mountpoint"; \
	    mkdir -p "$$mountpoint"; \
	    sudo mount -o loop "$$iso" "$$mountpoint"; \
	  done; \
	fi

unmount-isos:
	@ echo "Attempting to un-mount isos... "
	@ IFS=' ' read -r -a iso_files_array <<< "$$ISO_FILES"; \
    awk '{ print "sudo umount -lf "$$1 }' <(find $(REPO_DIR) -mindepth 1 -maxdepth 1) | sh ; \
	printf "Detaching loop devices... " ; \
    losetup | awk '/loop/ { print "sudo losetup -d "$$1 }' | sh
