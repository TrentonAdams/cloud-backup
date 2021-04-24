
.PHONY: clean
clean:
	@rm -f cloud-tar

.PHONY: tests
tests:
	./test/libs/bats/bin/bats test/*.bats

cloud-tar: tests
	@sed -e '/source components\/show-help.sh/ {' \
		-e 'r components/show-help.sh' \
		-e 'd' \
		-e '}' \
		-e '/source components\/parse-args.sh/ {' \
		-e 'r components/parse-args.sh' \
		-e 'd' \
		-e '}' \
		cloud-tar.sh > cloud-tar
	@chmod a+x cloud-tar
	@echo './cloud-tar built'