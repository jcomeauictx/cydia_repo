DISTRO := dists/itouch-1.1.4/main/binary-darwin-arm
REMOTE_REPO := /var/www/unternet.net/apt/$(DISTRO)
DRYRUN := --dry-run
PROJECTS := $(shell cd src && ls)
# define server1, server2, etc. in /etc/hosts
SERVER ?= server1
export
default: upload
set:
	set
src/%/DEBIAN/control:
	mkdir -p $(DISTRO) src && cd src && \
	 mkdir -p $* $*/DEBIAN $*/Applications/$*.app \
	  $*/System/Library/LaunchDaemons
	if [ ! -e src/$*/DEBIAN/control ]; then \
	 cp control.template src/$*/DEBIAN/control; \
	 vi src/$*/DEBIAN/control; \
	fi
$(DISTRO)/%.deb: src/%/DEBIAN/control
	cd src && dpkg -b $*
	mv -f src/$*.deb $@
Packages.gz: $(addprefix $(DISTRO)/, $(addsuffix .deb, $(PROJECTS))) .FORCE
	dpkg-scanpackages -m $(DISTRO) /dev/null | gzip > $@
upload: Packages.gz
	ssh $(SERVER) mkdir -p $(REMOTE_REPO)
	rsync -acvz $(DRYRUN) $< $(SERVER):$(REMOTE_REPO)/
	cd $(DISTRO) && rsync -acvz $(DRYRUN) . $(SERVER):$(REMOTE_REPO)/
.FORCE:
control:
	vi $$(find . -name control)
