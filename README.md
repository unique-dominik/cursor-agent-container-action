# Cursor Agent Container Action

> **⚠️ Disclaimer:** This is an unofficial wrapper action that downloads and runs [Cursor Agent](https://cursor.com). This project is not affiliated with, endorsed by, or sponsored by Anysphere Inc. (Cursor). Cursor Agent and all its components are subject to the [Cursor License](https://cursor.com/license.txt).

A GitHub Action wrapper to run Cursor Agent in a container for AI-powered coding tasks.

## Usage

### Basic usage with inline prompt

```yaml
steps:
  - name: Checkout
    uses: actions/checkout@v4

  - name: Run Cursor Agent
    uses: unique-dominik/cursor-agent-container-action@v1
    with:
      prompt: "Fix the linting errors in src/"
      cursor-api-key: ${{ secrets.CURSOR_API_KEY }}
```

### Advanced usage with template file

Use a prompt template file with environment variable substitution:

```yaml
steps:
  - name: Checkout
    uses: actions/checkout@v4

  - name: Perform code review
    uses: unique-dominik/cursor-agent-container-action@v1
    env:
      GITHUB_REPOSITORY: ${{ github.repository }}
      PR_NUMBER: ${{ github.event.pull_request.number }}
      PR_HEAD_SHA: ${{ github.event.pull_request.head.sha }}
      PR_BASE_SHA: ${{ github.event.pull_request.base.sha }}
    with:
      cursor-api-key: ${{ secrets.CURSOR_API_KEY }}
      prompt-file: .cursor/workflow.rate-pr.md
      envsubst-vars: "${GITHUB_REPOSITORY} ${PR_NUMBER} ${PR_HEAD_SHA} ${PR_BASE_SHA}"
      model: sonnet-4.5
      output-format: text
      force: "true"
      print: "true"
```

## Inputs

| Input                  | Description                                                      | Required | Default                 |
| ---------------------- | ---------------------------------------------------------------- | -------- | ----------------------- |
| `prompt`               | The prompt to send to Cursor Agent (use this OR `prompt-file`)  | No*      | -                       |
| `prompt-file`          | Path to a prompt template file (supports envsubst)              | No*      | -                       |
| `envsubst-vars`        | Space-separated env vars to substitute (e.g., `${VAR1} ${VAR2}`) | No       | -                       |
| `cursor-api-key`       | Cursor API key for authentication (use secrets!)                | Yes      | -                       |
| `cursor-agent-version` | Cursor Agent version to use                                      | No       | `2025.12.17-996666f`    |
| `model`                | Model to use (e.g., `sonnet-4.5`, `claude-3-opus`)              | No       | -                       |
| `force`                | Run with `--force` flag                                          | No       | `false`                 |
| `output-format`        | Output format (`text`, `json`)                                   | No       | -                       |
| `print`                | Print output to stdout (`--print` flag)                          | No       | `false`                 |

\* Either `prompt` or `prompt-file` must be provided.

## Setup

1. Get your Cursor API key from [cursor.com](https://cursor.com)
2. Add it as a repository secret named `CURSOR_API_KEY`
3. Use the action in your workflow

## Security

This action downloads Cursor Agent directly from Cursor's CDN (no `curl | bash`). The version can be pinned via the `cursor-agent-version` input for reproducibility.

Default version: `2025.12.17-996666f`

> [!NOTE]
> Future improvements could include checksum verification if Cursor provides signed releases.

## Development

### Build the container locally

```bash
docker build -t cursor-agent-container-action .
```

### Test the container

```bash
docker run \
  --env CURSOR_API_KEY="your-key" \
  --env INPUT_PROMPT="Hello" \
  --env INPUT_CURSOR_AGENT_VERSION="2025.12.17-996666f" \
  cursor-agent-container-action
```

## License

**This wrapper action:** See [LICENSE](./LICENSE) for details.

**Cursor Agent:** Cursor Agent is proprietary software owned by Anysphere Inc. By using this action, you agree to the [Cursor License Agreement](https://cursor.com/license.txt). This wrapper merely automates the download and execution of Cursor Agent in a GitHub Actions environment—it does not modify, redistribute, or bundle Cursor Agent itself.
