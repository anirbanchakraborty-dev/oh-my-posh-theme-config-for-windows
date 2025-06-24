#!/usr/bin/bash

# Define paths
THEME_PATH="$POSH_THEMES_PATH/hul10.omp.json"
MODIFIED_THEME_PATH="$HOME/Documents/Projects/ShellProjects/oh-my-posh-theme-config-for-windows/hul10_modified.omp.json"
BASHRC_PATH="$HOME/.bashrc"

# Modify the theme
MODIFIED_THEME=$(jq 'del(.blocks[] | select(.type == "prompt" and .alignment == "right"))' "$THEME_PATH")
echo "$MODIFIED_THEME" > "$MODIFIED_THEME_PATH"
echo "✅ Theme modified and saved to $MODIFIED_THEME_PATH"

# Define block to inject
read -r -d '' FINAL_BLOCK << EOF
# --- Enable history ---
PROMPT_COMMAND="history -a; history -c; history -r"

# --- Setup Oh My Posh ---
if command -v oh-my-posh &> /dev/null && [ -f "$MODIFIED_THEME_PATH" ]; then
  eval "\$(oh-my-posh init bash --config $MODIFIED_THEME_PATH)"
fi
EOF

# Step 1: Remove exact previous version of the block
awk -v block="$FINAL_BLOCK" '
BEGIN {
  split(block, blines, "\n")
  blen = length(blines)
}
{
  buffer[NR] = $0
}
END {
  for (i = 1; i <= NR - blen + 1; i++) {
    is_match = 1
    for (j = 0; j < blen; j++) {
      if (buffer[i + j] != blines[j + 1]) {
        is_match = 0
        break
      }
    }
    if (is_match) {
      for (j = i; j < i + blen; j++) delete buffer[j]
      i += blen - 1
    }
  }
  for (k = 1; k <= NR; k++) if (k in buffer) print buffer[k]
}' "$BASHRC_PATH" > "${BASHRC_PATH}.tmp" && mv "${BASHRC_PATH}.tmp" "$BASHRC_PATH"

# Step 2: Insert the block before Eza section or at the top
if grep -q '^# ---- Eza (better ls) -----' "$BASHRC_PATH"; then
  awk -v block="$FINAL_BLOCK" '
  BEGIN {
    split(block, lines, "\n")
    inserted = 0
  }
  {
    if (!inserted && $0 ~ /^# ---- Eza \(better ls\) -----/) {
      for (i = 1; i <= length(lines); i++) print lines[i]
      print ""
      inserted = 1
    }
    print $0
  }' "$BASHRC_PATH" > "${BASHRC_PATH}.tmp" && mv "${BASHRC_PATH}.tmp" "$BASHRC_PATH"
else
  awk -v block="$FINAL_BLOCK" '
  BEGIN {
    split(block, lines, "\n")
    for (i = 1; i <= length(lines); i++) print lines[i]
  }
  {
    print
  }' "$BASHRC_PATH" > "${BASHRC_PATH}.tmp" && mv "${BASHRC_PATH}.tmp" "$BASHRC_PATH"
fi

# Optional font installations
oh-my-posh font install "CascadiaCode"
oh-my-posh font install "CascadiaCode (MS)"
oh-my-posh font install "FiraCode"
oh-my-posh font install "JetBrainsMono"
oh-my-posh font install "Meslo"
oh-my-posh font install "NerdFontsSymbolsOnly"
oh-my-posh font install "SourceCodePro"

echo ""
echo "🎉 Setup complete! Your .bashrc is neat, idempotent, and 100% under control."
