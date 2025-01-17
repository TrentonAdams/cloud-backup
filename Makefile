
.PHONY: clean
clean:
	@rm -f cloud-tar cloud-tar-* cloud-tar.tar.gz

.PHONY: tests
tests:
	./test/libs/bats/bin/bats test/*.bats

cloud-tar:
	@sed -e '/source components\/show-help.sh/ {' \
		-e 'r components/show-help.sh' \
		-e 'd' \
		-e '}' \
		-e '/source components\/parse-commands.sh/ {' \
		-e 'r components/parse-commands.sh' \
		-e 'd' \
		-e '}' \
		-e '/source components\/parse-backup-args.sh/ {' \
		-e 'r components/parse-backup-args.sh' \
		-e 'd' \
		-e '}' \
		-e '/source components\/parse-restore-args.sh/ {' \
		-e 'r components/parse-restore-args.sh' \
		-e 'd' \
		-e '}' \
		-e '/source components\/restore.sh/ {' \
		-e 'r components/restore.sh' \
		-e 'd' \
		-e '}' \
		-e '/source components\/backup.sh/ {' \
		-e 'r components/backup.sh' \
		-e 'd' \
		-e '}' \
		cloud-tar.sh > cloud-tar
	@chmod a+x cloud-tar
	@echo './cloud-tar built'

# Test with this...
# GITHUB_REF=refs/tags/2.0.0.RC2 make clean cloud-tar release.tar.gz
release.tar.gz: cloud-tar
	tar -cvzf release.tar.gz cloud-tar
	cp release.tar.gz cloud-tar-$${GITHUB_REF#refs/tags/}.tar.gz


.PHONY: install
install: cloud-tar
	sudo install -m 755 -o root cloud-tar /usr/local/bin/

.PHONY: uninstall
uninstall: clean
	@sudo rm -f /usr/local/bin/cloud-tar
