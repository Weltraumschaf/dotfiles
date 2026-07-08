---
name: write-commit-messages
description: >-
    Formatting rules for git commit messages. Use this BEFORE running
    `git commit` or writing any commit message — whenever committing,
    staging and committing, creating a commit, or amending a commit.
---
# Write Commit Messages

Apply these rules every time you write a git commit message. For background see
[Chris Beams' article](https://chris.beams.io/posts/git-commit/).

## Rules

1. Separate the subject from the body with a blank line.
2. If the change relates to an issue, start the subject with its number
   (e.g. `#42 Add the Answer to Life, the Universe, and Everything`).
   If there is no associated issue, do not invent one — just omit it.
3. Limit the subject line to 50 characters.
4. Capitalize the subject line.
5. Do not end the subject line with a period.
6. Use the imperative mood in the subject line ("Add", not "Added" / "Adds").
7. Wrap the body at 72 characters.
8. Use the body to explain *what* changed and *why*. Do not explain *how* —
   that is already obvious from the diff.

## Do not include

- `@mentions` (e.g. `@octocat`).
- Auto-closing keywords such as `fixes #42`, `closes #42`, `resolves #42`.
  A bare reference like `#42` in the subject is fine; the closing keywords
  are not.

## Example

```text
#42 Add Retry Logic to the Payment Webhook Handler

The webhook occasionally arrived before the order row was committed,
causing the handler to 404 and the provider to give up after one try.

Retry the lookup with exponential backoff (up to 3 attempts) so the
handler tolerates the race instead of dropping legitimate events.
```
