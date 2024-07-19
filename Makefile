TestName=test-ubuntu

.PHONY: build output build-test
build:
	@echo "Building..."
	docker build -f ./base-ubuntu.Dockerfile -t base-ubuntu:latest .

output:
	@echo "Outputting..."
	@docker run --rm --env STDOUT=1 base-ubuntu:latest /usr/glibc-compat > glibc-bin.tar.gz


build-test:
	@echo "Building test image..."
	docker build -f ./$(TestName).Dockerfile -t $(TestName):latest .


run-test: clean-test
	@echo "Running test image..."
	@docker run -it -d --name $(TestName) --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro  -v /run/dbus/system_bus_socket:/run/dbus/system_bus_socket:ro -v /run/dbus:/run/dbus --cap-add SYS_ADMIN "$(TestName)" /bin/bash

clean-test:
	@if [ $$(docker ps -a -q -f name="$(TestName)") ]; then \
		echo "Container "$(TestName)" exists. Removing..."; \
		docker rm -f "$(TestName)"; \
	else \
		echo "Container "$(TestName)" does not exist."; \
	fi