#!/usr/bin/env bash
# =============================================================================
# SDD v3 — Global Command Installer
# tools/install-global-commands.sh
# Installs standard shims for SDD v3 workflow automation
# =============================================================================

set -euo pipefail

COMMANDS=("run-ticket" "close-ticket" "generate-new-agent-context" "sync-project")
INSTALL_DIR="/usr/local/bin"

echo "Installing SDD v3 global commands to $INSTALL_DIR..."

for CMD in "${COMMANDS[@]}"; do
    TMP_FILE="/tmp/$CMD"
    
    if [[ "$CMD" == "close-ticket" ]]; then
        cat <<EOF > "$TMP_FILE"
#!/usr/bin/env bash
# $CMD — SDD v3 project-relative closure wrapper
# Automatically resolves the project root and calls scripts/$CMD.sh

# Validation: Exactly two arguments required
if [ "\$#" -ne 2 ]; then
    echo "Usage: $CMD <TICKET_ID> \"<COMMIT_MESSAGE>\""
    exit 1
fi

# Resolve current git root
GIT_ROOT=\$(git rev-parse --show-toplevel 2>/dev/null)

if [ -z "\$GIT_ROOT" ]; then
    echo "Error: Not inside a git repository."
    exit 1
fi

HELPER_PATH="\${GIT_ROOT}/scripts/$CMD.sh"

if [ ! -x "\$HELPER_PATH" ]; then
    echo "Error: Helper script not found or not executable at: \$HELPER_PATH"
    echo "Ensure your project follows SDD v3 standards and has scripts/$CMD.sh"
    exit 1
fi

# Delegate to the project-level helper
"\$HELPER_PATH" "\$1" "\$2"
EOF
    else
        cat <<EOF > "$TMP_FILE"
#!/usr/bin/env bash
# $CMD — SDD v3 project-relative helper wrapper
# Automatically resolves the project root and calls scripts/$CMD.sh

# Resolve current git root
GIT_ROOT=\$(git rev-parse --show-toplevel 2>/dev/null)

if [ -z "\$GIT_ROOT" ]; then
    echo "Error: Not inside a git repository."
    exit 1
fi

HELPER_PATH="\${GIT_ROOT}/scripts/$CMD.sh"

if [ ! -x "\$HELPER_PATH" ]; then
    echo "Error: Helper script not found or not executable at: \$HELPER_PATH"
    echo "Ensure your project follows SDD v3 standards and has scripts/$CMD.sh"
    exit 1
fi

# Delegate to the project-level helper
"\$HELPER_PATH" "\$@"
EOF
    fi

    chmod +x "$TMP_FILE"
    sudo mv "$TMP_FILE" "$INSTALL_DIR/$CMD"
    sudo chown root:wheel "$INSTALL_DIR/$CMD"
    echo "✓ Installed: $INSTALL_DIR/$CMD"
done

echo ""
echo "All SDD v3 global commands installed successfully."
