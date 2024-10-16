#!/bin/bash

# Directory containing all GitHub repositories
REPOS_DIR="/home/meulindux/com.github.alexandreffaria"

# Function to fix push rejection for a single repository
fix_repo_push() {
    local repo_path="$1"
    echo "Fixing repository: $repo_path"
    cd "$repo_path" || return

    # Check if it's a git repository
    if [ ! -d .git ]; then
        echo "Not a git repository. Skipping."
        return
    fi

    # Get the repository name from the path
    repo_name=$(basename "$repo_path")

    # Check if 'origin' remote exists, if not, add it
    if ! git remote | grep -q '^origin$'; then
        echo "No 'origin' remote found. Adding it now."
        git remote add origin "git@github.com:alexandreffaria/${repo_name}.git"
        echo "Added remote: git@github.com:alexandreffaria/${repo_name}.git"
    else
        echo "Origin remote already exists. Updating URL."
        git remote set-url origin "git@github.com:alexandreffaria/${repo_name}.git"
    fi

    # Fetch remote content
    if ! git fetch origin; then
        echo "Failed to fetch from origin. Check your SSH keys and remote URL."
        echo "Remote URL: $(git remote get-url origin)"
        return
    fi

    # Check if main branch exists locally
    if git show-ref --verify --quiet refs/heads/main; then
        main_branch="main"
    elif git show-ref --verify --quiet refs/heads/master; then
        main_branch="master"
    else
        echo "Neither main nor master branch found. Creating main branch."
        git checkout -b main
        main_branch="main"
    fi

    # Check if the branch exists on the remote
    if ! git ls-remote --exit-code --heads origin "$main_branch" >/dev/null 2>&1; then
        echo "The $main_branch branch doesn't exist on the remote. Pushing it."
        git push -u origin "$main_branch"
    else
        # If branch exists, ensure we're up to date
        git reset --hard "origin/$main_branch"
    fi

    # Apply any local changes if they exist
    if git rev-parse --verify backup-"$main_branch" >/dev/null 2>&1; then
        if git cherry-pick "backup-$main_branch" 2>/dev/null; then
            # Force push updated main/master
            if git push -f origin "$main_branch"; then
                echo "Changes have been successfully pushed to the remote repository."
            else
                echo "Failed to push changes. Check your permissions on the remote repository."
            fi
        else
            echo "No changes to apply or conflicts occurred in $repo_path."
            echo "You may need to manually resolve conflicts in this repository."
        fi
        # Clean up
        git branch -D "backup-$main_branch" 2>/dev/null || true
    else
        echo "No local changes to apply."
    fi

    echo "Repository fix attempt complete."
    echo "-------------------------"
}

# Main script
echo "Starting multi-repository fix process..."

# Iterate through all directories in the REPOS_DIR
for repo in "$REPOS_DIR"/*; do
    if [ -d "$repo" ]; then
        fix_repo_push "$repo"
    fi
done

echo "All repositories have been processed."