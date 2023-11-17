#!/bin/bash
function getMemoryInfo() {
  # Get all the running KVM instances
  running_instances=$(virsh list | grep running | awk '{print $2}')

  # Iterate over the running instances and get the memory info
  rm -rf /tmp/.nkmem
  for instance in ${running_instances[@]}; do
    # Get the total memory allocated to the instance in GBs
    total_memory=$(virsh dommemstat $instance | grep actual | awk '{print $2}')
    total_memory_gb=$(echo "scale=2; $total_memory / 1024 / 1024" | bc)

    # Create a formatted memory info string
    formatted_memory_info="$instance ${total_memory_gb}"

    # Print the formatted memory info string to the console
    touch /tmp/.nkmem
    echo "$formatted_memory_info" >> /tmp/.nkmem
  done
  # Print the header
  echo -e "-----------------------------------"
  echo -e "Virtual Instance Memory Information:"
  echo -e "-----------------------------------"
  cat /tmp/.nkmem | column -t -s " "
  # Print the footer
  echo -e "-----------------------------------"
  rm -rf /tmp/.nkmem
}

function deleteVM() {
# Check if at least one argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <instance_name1> [<instance_name2> ...]"
    exit 1
fi

# Loop through each instance name provided as an argument
for instance_name in "$@"; do
    # Destroy the virtual machine
    virsh destroy "$instance_name"

    # Undefine and remove all storage associated with the virtual machine
    virsh undefine "$instance_name" --remove-all-storage

    # Print a message for each instance processed
    echo "Instance '$instance_name' destroyed and removed."
done

echo "All specified instances have been destroyed and removed."
}
