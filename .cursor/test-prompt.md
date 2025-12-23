# Self-Test Prompt

This is a simple test to verify the Cursor Agent Container Action works
correctly.

## Instructions

1. Read the `README.md` file in the workspace
2. Confirm you can access the repository files
3. Generate a brief summary confirming the action is working
4. Post a comment on PR #${PR_NUMBER} with the following format:
   - Include the current date/time (last run date)
   - Include the summary output from step 3

Use the GitHub CLI to post the comment:
```bash
gh pr comment ${PR_NUMBER} --body "## Cursor Agent Self-Test

**Last run:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")

**Output:**
[Your summary here]"
```

**Expected result:** A PR comment should be posted with the last run date and the test output summary.
