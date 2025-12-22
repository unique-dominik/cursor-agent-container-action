# Cursor Agent Container Action
#
# This is a wrapper that downloads and runs Cursor Agent at runtime.
# Cursor Agent is proprietary software by Anysphere Inc.
# License: https://cursor.com/license.txt
#

# Use Debian slim as base image (glibc required for Cursor CLI binaries)
FROM debian:bookworm-slim

# Install dependencies required for Cursor CLI
# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /usr/src

# Add Cursor CLI location to PATH
ENV PATH="/root/.local/bin:${PATH}"

# Copy the entrypoint script
COPY entrypoint.sh .

# Configure the container to be run as an executable
ENTRYPOINT ["/usr/src/entrypoint.sh"]
