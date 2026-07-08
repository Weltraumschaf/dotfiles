---
name: write-commit-messages
description: >-
  Formatting rules for git commit messages. Use this BEFORE running
  `git commit` or writing any commit message — whenever committing,
  staging and committing, creating a commit, or amending a commit.
---
# Write Commit Messages

For more information see [Chris Beams article](https://chris.beams.io/posts/git-commit/).

TL;DR

1. Separate the subject from the body with a blank line.
2. Add the issue number at the beginning of to the subject line (e.g. "#42 Add the Answer to the Live, Universe, and the Rest")
3. Limit the subject line to 50 characters.
4. Capitalize the subject line.
5. Do not end the subject line with a period.
6. Use the imperative mood in the subject line.
7. Wrap the body at 72 characters.
8. Use the body to explain what and why (not how because this is obvious from the diff).

NOTE: Make sure you don't include @mentions or fixes keywords in your git commit messages.
