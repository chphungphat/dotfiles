#!/bin/bash

# Directory where tmux-resurrect saves sessions
resurrect_dir="${HOME}/.config/tmux/resurrect-saves"

# Ensure the directory exists
if [ ! -d "$resurrect_dir" ]; then
  echo "Resurrect directory not found: $resurrect_dir"
  exit 1
fi

# List saved sessions
echo "Saved tmux sessions:"
sessions=("$resurrect_dir"/tmux_resurrect_*.txt)
select session in "${sessions[@]}"; do
  if [ -n "$session" ]; then
    echo "Selected: $session"
    break
  else
    echo "Invalid selection. Please try again."
  fi
done

# Prompt for action
echo "What would you like to do with this session?"
options=("Delete" "Set as last" "Exit")
select opt in "${options[@]}"; do
  case $opt in
    "Delete")
      rm -f "$session"
      echo "Deleted: $session"
      break
      ;;
    "Set as last")
      ln -sf "$(basename "$session")" "$resurrect_dir/last"
      echo "Set as last: $session"
      break
      ;;
    "Exit")
      echo "No action taken."
      break
      ;;
    *)
      echo "Invalid option. Please try again."
      ;;
  esac
done
