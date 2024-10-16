#!/bin/bash

# New author information
NEW_NAME="Alex. F"
NEW_EMAIL="alexandrefonsecaffaria@gmail.com"

# Get the total number of commits
TOTAL_COMMITS=$(git rev-list --count --all)

echo "Checking and updating $TOTAL_COMMITS commits..."

# Use git filter-repo to change the author information
git filter-repo --force --commit-callback "
# List of old names and emails to replace
old_names = [b'Alexandre Faria', b'Alexandre F', b'Alex. F', b'\xc2\xa8Alexandre', b'Alexandre', b'melipe']
old_emails = [b'alexandreffaria@me.com', b'alexandrefonsecaffaria@gmail.com', b'alexandrefosnecaffaria@gmail.com', b'\xc2\xa8alexandrefonsecaffaria@gmail.com\xc2\xa8', b'fodas@gmail.com']

if commit.author_name in old_names or commit.author_email in old_emails:
    commit.author_name = b'$NEW_NAME'
    commit.author_email = b'$NEW_EMAIL'
if commit.committer_name in old_names or commit.committer_email in old_emails:
    commit.committer_name = b'$NEW_NAME'
    commit.committer_email = b'$NEW_EMAIL'
"

echo "Commits have been updated. Please review the changes."
echo "If everything looks correct, force push to your remote repository with:"
echo "git push --force origin main"
