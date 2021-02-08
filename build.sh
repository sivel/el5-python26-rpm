#!/usr/bin/env bash
docker build --rm -t centos-el5-python26-rpm .
mkdir -p $(pwd)/rpms/
docker cp $(docker create --rm centos-el5-python26-rpm:latest):/rpms $(pwd)/