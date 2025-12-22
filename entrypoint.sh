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

# Resolve the prompt (either direct or from file with envsubst)
PROMPT=""
if [ -n "$INPUT_PROMPT" ]; then
    PROMPT="$INPUT_PROMPT"
elif [ -n "$INPUT_PROMPT_FILE" ]; then
    if [ ! -f "$INPUT_PROMPT_FILE" ]; then
        echo "::error::Prompt file not found: $INPUT_PROMPT_FILE"
        exit 1
    fi
    echo "::debug::Reading prompt from file: $INPUT_PROMPT_FILE"
    if [ -n "$INPUT_ENVSUBST_VARS" ]; then
        PROMPT=$(envsubst "$INPUT_ENVSUBST_VARS" < "$INPUT_PROMPT_FILE")
    else
        PROMPT=$(cat "$INPUT_PROMPT_FILE")
    fi
else
    echo "::error::Either 'prompt' or 'prompt-file' must be provided"
    exit 1
fi

# Build cursor-agent command arguments
CURSOR_ARGS=()

if [ "$INPUT_FORCE" = "true" ]; then
    CURSOR_ARGS+=("--force")
fi

if [ -n "$INPUT_MODEL" ]; then
    CURSOR_ARGS+=("--model" "$INPUT_MODEL")
fi

if [ -n "$INPUT_OUTPUT_FORMAT" ]; then
    CURSOR_ARGS+=("--output-format=$INPUT_OUTPUT_FORMAT")
fi

if [ "$INPUT_PRINT" = "true" ]; then
    CURSOR_ARGS+=("--print")
fi

# Add the prompt as the last argument
CURSOR_ARGS+=("$PROMPT")

# Run cursor-agent with all arguments
echo "::group::Running Cursor Agent"
echo "::debug::Command: cursor-agent ${CURSOR_ARGS[*]}"
cursor-agent "${CURSOR_ARGS[@]}"
echo "::endgroup::"

exit 0
