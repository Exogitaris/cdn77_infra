# Use the Debian workbook as the base image
FROM debian:bookworm

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install Kafka
RUN apt-get update && \
apt-get install -y wget && \
wget https://download.oracle.com/java/22/latest/jdk-22_linux-x64_bin.deb -P /opt && \
dpkg -i /opt/jdk-22_linux-x64_bin.deb && \
wget https://dlcdn.apache.org/kafka/3.7.0/kafka_2.13-3.7.0.tgz -P /opt && \
tar -xzf /opt/kafka_2.13-3.7.0.tgz -C /opt && \
mv /opt/kafka_2.13-3.7.0 /opt/kafka && \
rm /opt/kafka_2.13-3.7.0.tgz && \
rm /opt/jdk-22_linux-x64_bin.deb
