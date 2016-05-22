#!/bin/bash
CWD="$(pwd)"
cd "$(git rev-parse --show-toplevel)" &&
docker build -t pmc . &&
for i in Docker/Dockerfile_*;do
	docker build -t "pmc_${i##*_}" -f "${i}" .
done
cd "${CWD}"
