# Cursor Agent Container Action

A GitHub Action wrapper to run Cursor Agent in a container for AI-powered coding
tasks.

> [!CAUTION]
> **⚠️ Disclaimer:** This is an unofficial wrapper action that downloads and
> runs [Cursor Agent](https://cursor.com). This project is not affiliated with,
> endorsed by, or sponsored by Anysphere Inc. (Cursor). Cursor Agent and all its
> components are subject to the
> [Cursor License](https://cursor.com/license.txt).

> [!WARNING]
> While a pre-built Docker image would be the preferred approach, this implementation uses a container action to enable faster development iteration cycles during the initial development phase.

## Usage

Create a prompt file in your repository (e.g., `.cursor/my-prompt.md`) and
reference it in your workflow:

```yaml
steps:
  - name: Checkout
    uses: actions/checkout@v6

  - name: Run Cursor Agent
    uses: unique-dominik/cursor-agent-container-action@<sha>
    with:
      cursor-api-key: ${{ secrets.CURSOR_API_KEY }}
      prompt-file: .cursor/my-prompt.md
```

### With environment variable substitution

Use `envsubst` to inject dynamic values into your prompt template:

```yaml
steps:
  - name: Checkout
    uses: actions/checkout@v6

  - name: Perform code review
    uses: unique-dominik/cursor-agent-container-action@<sha>
    env:
      GITHUB_REPOSITORY: ${{ github.repository }}
      PR_NUMBER: ${{ github.event.pull_request.number }}
      PR_HEAD_SHA: ${{ github.event.pull_request.head.sha }}
      PR_BASE_SHA: ${{ github.event.pull_request.base.sha }}
    with:
      cursor-api-key: ${{ secrets.CURSOR_API_KEY }}
      prompt-file: .cursor/workflow.rate-pr.md
      envsubst-vars:
        '${GITHUB_REPOSITORY} ${PR_NUMBER} ${PR_HEAD_SHA} ${PR_BASE_SHA}'
      model: sonnet-4.5
      output-format: text
      force: 'true'
      print: 'true'
```

### With GitHub CLI access

Pass a GitHub token to enable `gh` CLI commands (e.g., for PR comments):

```yaml
steps:
  - name: Checkout
    uses: actions/checkout@v6

  - name: Run Cursor Agent with GitHub access
    uses: unique-dominik/cursor-agent-container-action@<sha>
    with:
      cursor-api-key: ${{ secrets.CURSOR_API_KEY }}
      github-token: ${{ github.token }}
      prompt-file: .cursor/review-and-comment.md
```

The `gh` CLI is pre-installed and will automatically authenticate using the
provided token. Your prompt can then use commands like:

```bash
gh pr comment $PR_NUMBER --body "Review complete!"
gh issue comment $ISSUE_NUMBER --body "Analysis results..."
```

> **Note:** Use `${{ github.token }}` for default repository permissions. For
> cross-repo access or elevated permissions, use a Personal Access Token (PAT)
> stored as a secret.

## Inputs

| Input                  | Description                      | Required | Default              |
| ---------------------- | -------------------------------- | -------- | -------------------- |
| `cursor-agent-version` | Cursor Agent version             | No       | `2025.12.17-996666f` |
| `cursor-api-key`       | API key for auth (use secrets!)  | Yes      | -                    |
| `envsubst-vars`        | Env vars to substitute           | No       | -                    |
| `force`                | Run with `--force` flag          | No       | `false`              |
| `github-token`         | GitHub token for `gh` CLI access | No       | -                    |
| `model`                | Model (e.g., `sonnet-4.5`)       | No       | -                    |
| `output-format`        | Output format (`text`, `json`)   | No       | -                    |
| `print`                | Print output (`--print` flag)    | No       | `false`              |
| `prompt-file`          | Path to prompt template file     | Yes      | -                    |

## Setup

1. Get your Cursor API key from [cursor.com](https://cursor.com)
1. Add it as a repository secret named `CURSOR_API_KEY`
1. Create a prompt file in your repository
1. Use the action in your workflow

## Security

This action only accepts **file-based prompts** (no inline prompt input). This
design choice prevents prompt injection attacks via workflow inputs and ensures
all prompts are committed to the repository for auditability.

The action downloads Cursor Agent directly from Cursor's CDN (no `curl | bash`).
The version can be pinned via the `cursor-agent-version` input for
reproducibility.

Default version: `2025.12.17-996666f`

> [!NOTE] Future improvements could include checksum verification if Cursor
> provides signed releases.

## Development

### Build the container locally

```bash
docker build -t cursor-agent-container-action .
```

### Test the container

```bash
echo "Hello, World!" > /tmp/test-prompt.md
docker run --rm \
  -v /tmp/test-prompt.md:/github/workspace/prompt.md \
  --env CURSOR_API_KEY="your-key" \
  --env INPUT_PROMPT_FILE="prompt.md" \
  --env INPUT_CURSOR_AGENT_VERSION="2025.12.17-996666f" \
  cursor-agent-container-action
```

## License

**This wrapper action:** See [LICENSE](./LICENSE) for details.

**Cursor Agent:** Cursor Agent is proprietary software owned by Anysphere Inc.
By using this action, you agree to the
[Cursor License Agreement](https://cursor.com/license.txt). This wrapper merely
automates the download and execution of Cursor Agent in a GitHub Actions
environment—it does not modify, redistribute, or bundle Cursor Agent itself.
