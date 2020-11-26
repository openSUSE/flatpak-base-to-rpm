
docker-base:
	docker build -t flatpak-base -f Dockerfile.base .
docker-builder:
	docker build -t flatpak-builder -f Dockerfile.builder .
