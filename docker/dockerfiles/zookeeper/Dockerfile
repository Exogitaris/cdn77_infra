# Use the Debian workbook as the base image
FROM debian:bookworm

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install Zookeeper
RUN apt-get update && \
apt-get install -y wget && \
wget https://download.oracle.com/java/22/latest/jdk-22_linux-x64_bin.deb -P /opt && \
dpkg -i /opt/jdk-22_linux-x64_bin.deb && \
wget https://dlcdn.apache.org/zookeeper/zookeeper-3.8.4/apache-zookeeper-3.8.4-bin.tar.gz -P /opt && \
tar -xzf /opt/apache-zookeeper-3.8.4-bin.tar.gz -C /opt && \
rm /opt/jdk-22_linux-x64_bin.deb && \
rm /opt/apache-zookeeper-3.8.4-bin.tar.gz && \
mv /opt/apache-zookeeper-3.8.4-bin /opt/zookeeper
