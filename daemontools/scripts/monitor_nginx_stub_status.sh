#!/bin/bash

# Function to get IP address of a Docker container by name
get_container_ip() {
    local container_name=$1
    docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container_name"
}

# Function to make a curl request and parse the output
make_curl_request() {
    local container_name=$1
    local container_ip=$2
    local response=$(curl -s -i "http://$container_ip/basic_status")
    
    local request_type="GET"
    local status_code=$(echo "$response" | grep -oP '(?<=HTTP/1.1 )\d+')
    #local nginx_version=$(echo "$response" | grep -oP '(?<=Server: nginx/)[\d.]+')
    local active_connections=$(echo "$response" | grep -oP '(?<=Active connections: )\d+')
    
    local accepts=$(echo "$response" | grep -oP '^\s*\d+\s+\d+\s+\d+' | awk '{print $1}')
    local handled=$(echo "$response" | grep -oP '^\s*\d+\s+\d+\s+\d+' | awk '{print $2}')
    local requests=$(echo "$response" | grep -oP '^\s*\d+\s+\d+\s+\d+' | awk '{print $3}')
    
    local reading=$(echo "$response" | grep -oP '(?<=Reading: )\d+')
    local writing=$(echo "$response" | grep -oP '(?<=Writing: )\d+')
    local waiting=$(echo "$response" | grep -oP '(?<=Waiting: )\d+')

    echo "nginx_ip_address=$container_ip, request_type=$request_type, status_code=$status_code, active_connections=$active_connections, server_accepts=$accepts, server_handled=$handled, server_requests=$requests, reading=$reading, writing=$writing, waiting=$waiting"
}

# Run the script periodically every 15 seconds
while true; do
    # Get IP addresses of the Docker containers
    nginx_proxy_server_ip=$(get_container_ip nginx_proxy_server)
    nginx_web_server_ip=$(get_container_ip nginx_web_server)

    # Make curl requests and parse the output
    make_curl_request "nginx_proxy_server" "$nginx_proxy_server_ip"
    make_curl_request "nginx_web_server" "$nginx_web_server_ip"

    # Wait for 15 seconds before the next iteration
    sleep 15
done
