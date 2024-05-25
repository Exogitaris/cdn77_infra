# Use the Debian workbook as the base image
FROM debian:bookworm

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update packages and install Nginx 
RUN apt-get update && \
  apt-get install -y sudo && \
	sudo apt install -y curl gnupg2 ca-certificates lsb-release debian-archive-keyring && \
	curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null && \
	gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg && \
	echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
	http://nginx.org/packages/debian `lsb_release -cs` nginx" \ 
	| sudo tee /etc/apt/sources.list.d/nginx.list && \
	echo "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \ 
	| sudo tee /etc/apt/preferences.d/99nginx && \
	sudo apt update && \
  sudo apt install -y nginx && \
	sudo nginx && \
  rm -rf /var/lib/apt/lists/*	&& \
	mkdir -p /www/data/
