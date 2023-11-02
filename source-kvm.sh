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
  # Check if the VM exists
  if ! virsh dominfo $1; then
    echo "VM $1 does not exist."
    return
  fi

  # Log that the VM is being deleted to the console
  echo "Deleting VM $1"

  # Stop the VM if it is running
  if virsh domstate $1 | grep running; then
    virsh destroy $1
  fi

  # Log that the VM has been stopped to the console
  echo "VM $1 has been stopped"

  # Undefine the VM with the `--remove-all-storage` option to delete all of its associated storage
  virsh undefine $1 --remove-all-storage

  # Log that the VM has been undefined to the console
  echo "VM $1 has been undefined"
}
