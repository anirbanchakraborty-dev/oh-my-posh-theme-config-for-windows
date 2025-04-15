#!/usr/bin/bash

# Define the paths
THEME_PATH="$POSH_THEMES_PATH/hul10.omp.json"
TEMP_THEME_PATH="$HOME/Documents/Projects/oh-my-posh-theme-config-for-windows/hul10_modified.omp.json"
BASHRC_PATH="$HOME/.bashrc"

# Read the original theme
ORIGINAL_THEME=$(cat "$THEME_PATH")

# Modify the theme by removing the shell name and date/time segments
MODIFIED_THEME=$(echo "$ORIGINAL_THEME" | jq 'del(.blocks[] | select(.type == "prompt" and .alignment == "right"))')

# Save the modified theme to the specified path
echo "$MODIFIED_THEME" > "$TEMP_THEME_PATH"

# Check if the lines already exist in .bashrc
if ! grep -q "Setup Oh My Posh" "$BASHRC_PATH"; then
  # Add the lines at the very top of .bashrc
  sed -i "1i # --- Enable history ---\nPROMPT_COMMAND='history -a;history -c;history -r'\n# --- Setup Oh My Posh ---\neval \"\$(oh-my-posh init bash --config $HOME/Documents/Projects/oh-my-posh-theme-config-for-windows/hul10_modified.omp.json)\"\n" "$BASHRC_PATH"
  echo ".bashrc updated successfully!"
else
  echo "The configuration lines already exist in .bashrc. No changes made."
fi

echo "Theme modified successfully!"