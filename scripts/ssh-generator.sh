#!/bin/bash

# Available SSH key algorithms
declare -a algorithms=("rsa" "ecdsa" "ed25519")

echo "Select an SSH key algorithm:"
select algo in "${algorithms[@]}"; do
  if [[ -n "$algo" ]]; then
    break
  else
    echo "Invalid choice. Please select a valid algorithm."
  fi
done

echo -n "Enter the name for the SSH key (default: id_$algo): "
read -r keyname

# Use default key name if empty
if [ -z "$keyname" ]; then
  keyname="id_$algo"
fi

keypath="$HOME/.ssh/$keyname"

# Generate the SSH key pair
if [[ "$algo" == "rsa" ]]; then
  ssh-keygen -t rsa -b 4096 -f "$keypath" -N ""
elif [[ "$algo" == "ecdsa" ]]; then
  ssh-keygen -t ecdsa -b 521 -f "$keypath" -N ""
elif [[ "$algo" == "ed25519" ]]; then
  ssh-keygen -t ed25519 -f "$keypath" -N ""
fi

# Set appropriate permissions
chmod 600 "$keypath"
chmod 644 "$keypath.pub"

echo "SSH key pair generated at: $keypath and $keypath.pub"
