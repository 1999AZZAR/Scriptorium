#!/bin/bash

# Install script for Aliases Collection
# This script clones the repository, sets up the aliases, and reloads your shell.

# Step 1: Download and extract the repository
REPO_URL="https://github.com/1999AZZAR/alias-hub/archive/refs/heads/master.zip"
ALIASES_DIR="$HOME/alias-hub"

# Check if wget is installed
if ! command -v wget &> /dev/null; then
    echo "wget is not installed. Please install wget and try again."
    exit 1
fi

# Download and extract the repository
echo "Downloading the aliases collection..."
wget -q -O alias-hub.zip "$REPO_URL"
unzip -q alias-hub.zip -d "$HOME"
mv "$HOME/alias-hub-master" "$ALIASES_DIR"
rm alias-hub.zip

# Step 2: Configure aliases in shell rc file
echo "Configuring shell to use aliases..."
SHELL_RC=""
if [[ $SHELL == *"bash"* ]]; then
    SHELL_RC="$HOME/.bashrc"
elif [[ $SHELL == *"zsh"* ]]; then
    SHELL_RC="$HOME/.zshrc"
else
    echo "Unsupported shell. Please configure manually."
    exit 1
fi

# Add sourcing script to the shell rc file
if ! grep -q "ALIASES_DIR=\"$ALIASES_DIR\"" "$SHELL_RC"; then
    echo -e "\n## Custom aliases\nALIASES_DIR=\"$ALIASES_DIR\"\nfor file in \"\$ALIASES_DIR\"/*.alias; do source \"\$file\"; done" >> "$SHELL_RC"
    echo "Aliases configured in $SHELL_RC."
else
    echo "Aliases are already configured in $SHELL_RC."
fi

# Step 3: Add autocompletion for alias-list command (only for .alias files)
echo "Configuring autocompletion for alias-list..."
AUTO_COMPLETE_CODE="
# Auto-completion for alias-list command (only for .alias files)
_alias_list_completions() {
    local current_word
    current_word=\"\${COMP_WORDS[COMP_CWORD]}\"

    # Get all alias file names, case-insensitive, matching the current word and ending with .alias
    local matches
    matches=\$(compgen -W \"\$(ls -1 \"\$ALIASES_DIR\" | grep -i \"^\$current_word\" | grep '\\.alias\$' | sed 's/\\.alias\$//')\" -- \"\$current_word\")

    # Output matches for autocompletion
    COMPREPLY=(\$matches)
}

# Enable completion for alias-list
complete -F _alias_list_completions alias-list
"
# Check if auto-completion is already in the rc file
if ! grep -q "_alias_list_completions" "$SHELL_RC"; then
    echo -e "$AUTO_COMPLETE_CODE" >> "$SHELL_RC"
    echo "Auto-completion configured in $SHELL_RC."
else
    echo "Auto-completion is already configured in $SHELL_RC."
fi

# Step 4: Reload the shell
echo "Reloading your shell..."
source "$SHELL_RC"
echo "Installation complete! Enjoy your enhanced shell experience."
