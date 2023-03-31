init:
	$(MAKE) -C test_deployment init && \
	$(MAKE) -C test_objects init

deploy_test_env:
	$(MAKE) -C test_deployment deploy && \
	$(MAKE) -C test_objects deploy

run_tests:
	$(MAKE) -C tests run_tests

test: deploy_test_env run_tests

clean:
	$(MAKE) -C test_deployment destroy; \
	$(MAKE) -C test_objects clean; \
