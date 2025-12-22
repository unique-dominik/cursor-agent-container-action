#!/bin/bash
#
# This script downloads and runs Cursor Agent from Cursor's CDN.
# Cursor Agent is proprietary software by Anysphere Inc.
# By using this script, you agree to the Cursor License: https://cursor.com/license.txt
#

set -e

# Default version if not specified
CURSOR_VERSION="${INPUT_CURSOR_AGENT_VERSION:-2025.12.17-996666f}"

# Ensure PATH includes cursor-agent location
export PATH="/root/.local/bin:${PATH}"

# Install Cursor Agent
install_cursor_agent() {
    echo "::group::Installing Cursor Agent ${CURSOR_VERSION}"
    
    # Detect architecture
    ARCH="$(dpkg --print-architecture)"
    case "${ARCH}" in
        amd64) CURSOR_ARCH="x64" ;;
        arm64) CURSOR_ARCH="arm64" ;;
        *)
            echo "::error::Unsupported architecture: ${ARCH}"
            exit 1
            ;;
    esac
    
    # Create installation directories
    INSTALL_DIR="/root/.local/share/cursor-agent/versions/${CURSOR_VERSION}"
    mkdir -p /root/.local/bin "${INSTALL_DIR}"
    
    # Download and extract
    DOWNLOAD_URL="https://downloads.cursor.com/lab/${CURSOR_VERSION}/linux/${CURSOR_ARCH}/agent-cli-package.tar.gz"
    echo "Downloading from: ${DOWNLOAD_URL}"
    
    if ! curl -fsSL "${DOWNLOAD_URL}" | tar --strip-components=1 -xzf - -C "${INSTALL_DIR}"; then
        echo "::error::Failed to download Cursor Agent ${CURSOR_VERSION}"
        exit 1
    fi
    
    # Create symlink (remove existing if present)
    rm -f /root/.local/bin/cursor-agent
    ln -s "${INSTALL_DIR}/cursor-agent" /root/.local/bin/cursor-agent
    
    echo "::endgroup::"
}

# Install cursor-agent if not present or version mismatch
INSTALLED_VERSION=""
if [ -x "/root/.local/bin/cursor-agent" ]; then
    INSTALLED_VERSION="$(/root/.local/bin/cursor-agent --version 2>/dev/null || echo "")"
fi

if [ "${INSTALLED_VERSION}" != "${CURSOR_VERSION}" ]; then
    install_cursor_agent
fi

# Print version for debugging
echo "::group::Cursor Agent Version"
cursor-agent --version
echo "::endgroup::"

# Run cursor-agent with the provided prompt
echo "::group::Running Cursor Agent"
cursor-agent "$INPUT_PROMPT"
echo "::endgroup::"

exit 0
