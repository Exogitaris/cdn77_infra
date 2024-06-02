#!/bin/bash

while true; do
    # Loop through all running Docker containers
    for container in $(docker ps -q); do
        # Get the container name
        container_name=$(docker inspect --format '{{.Name}}' "$container" | cut -c2-)
        
        # Execute the command inside the container and get the load avg values
        loadavg=$(docker exec "$container" cat /proc/loadavg)
        
        # Parse the load avg values
        load_avg_1min=$(echo "$loadavg" | awk '{print $1}')
        load_avg_5min=$(echo "$loadavg" | awk '{print $2}')
        load_avg_15min=$(echo "$loadavg" | awk '{print $3}')
        running_processes=$(echo "$loadavg" | awk '{print $4}' | cut -d'/' -f1)
        total_processes=$(echo "$loadavg" | awk '{print $4}' | cut -d'/' -f2)
        last_pid=$(echo "$loadavg" | awk '{print $5}')
        
        # Print the output
        echo "container_name=$container_name, load_avg_1min=$load_avg_1min, load_avg_5min=$load_avg_5min, load_avg_15min=$load_avg_15min, running_processes=$running_processes, total_processes=$total_processes, last_pid=$last_pid"
    done
    
    # Wait for 15 seconds before running the loop again
    sleep 15
done

