.PHONY: all lint fix build test clean

.DEFAULT_GOAL := all

# Fix, lint, and clean up
all: fix lint clean
	@echo "=== All done! ==="

# Run all linters (check mode)
lint: lint-yaml lint-markdown lint-shell lint-dockerfile lint-prettier

# Fix all auto-fixable issues
fix: fix-shell fix-prettier

# Build the Docker container
build:
	docker build -t cursor-agent-container-action .

# Test the container
test: build
	docker run --rm \
		--env INPUT_PROMPT="Hello, World!" \
		--env INPUT_CURSOR_AGENT_VERSION="2025.12.17-996666f" \
		cursor-agent-container-action || echo "Expected to fail without API key"

# Linting commands (check mode)
lint-yaml:
	@echo "=== YAML (yamllint) ==="
	docker run --rm -v "$(PWD)":/work -w /work \
		pipelinecomponents/yamllint yamllint .

lint-markdown:
	@echo "=== Markdown (markdownlint) ==="
	docker run --rm -v "$(PWD)":/work -w /work \
		davidanson/markdownlint-cli2 "**/*.md"

lint-shell:
	@echo "=== Shell (shellcheck) ==="
	docker run --rm -v "$(PWD)":/mnt \
		koalaman/shellcheck:stable /mnt/entrypoint.sh
	@echo "=== Shell (shfmt) ==="
	docker run --rm -v "$(PWD)":/work -w /work \
		mvdan/shfmt:latest -d entrypoint.sh

lint-dockerfile:
	@echo "=== Dockerfile (hadolint) ==="
	docker run --rm -v "$(PWD)":/work \
		hadolint/hadolint hadolint /work/Dockerfile

lint-prettier:
	@echo "=== Prettier ==="
	docker run --rm -v "$(PWD)":/work -w /work \
		node:20-slim npx prettier@latest --check .

# Fix commands (auto-fix mode)
fix-shell:
	@echo "=== Fixing shell with shfmt ==="
	docker run --rm -v "$(PWD)":/work -w /work \
		mvdan/shfmt:latest -w entrypoint.sh

fix-prettier:
	@echo "=== Fixing with prettier ==="
	docker run --rm -v "$(PWD)":/work -w /work \
		node:20-slim npx prettier@latest --write .

# Clean up Docker images used for linting
clean:
	-docker rmi pipelinecomponents/yamllint
	-docker rmi davidanson/markdownlint-cli2
	-docker rmi koalaman/shellcheck:stable
	-docker rmi mvdan/shfmt:latest
	-docker rmi hadolint/hadolint
	-docker rmi cursor-agent-container-action

