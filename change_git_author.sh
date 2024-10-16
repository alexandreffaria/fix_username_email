#!/bin/bash

# New author information
NEW_NAME="Alex. F"
NEW_EMAIL="alexandrefonsecaffaria@gmail.com"

# Directory containing all GitHub repositories
REPOS_DIR="/home/meulindux/com.github.alexandreffaria"

# Function to update author information and force push
update_repo() {
    local repo_path="$1"
    echo "Updating repository: $repo_path"
    cd "$repo_path" || return

    # Check if it's a git repository
    if [ ! -d .git ]; then
        echo "Not a git repository. Skipping."
        return
    fi  # This line was corrected (removed the curly brace)

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

    echo "Commits have been updated."

    # Force push to all remotes
    git remote | while read -r remote; do
        echo "Force pushing to remote: $remote"
        git push --force "$remote" --all
        git push --force "$remote" --tags
    done

    echo "Repository update complete."
    echo "-------------------------"
}

# Main script
echo "Starting multi-repository update process..."

# Iterate through all directories in the REPOS_DIR
for repo in "$REPOS_DIR"/*; do
    if [ -d "$repo" ]; then
        update_repo "$repo"
    fi
done

echo "All repositories have been processed."