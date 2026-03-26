#!/usr/bin/env bash

# Usage: ./sync_fork.sh <branch>
# Example: ./sync_fork.sh main

BRANCH=${1:-main}

# Ensure we're in a git repo
git rev-parse --is-inside-work-tree &>/dev/null || {
  echo "Not inside a git repository."
  exit 1
}

# Ensure upstream exists; if not, ask for its URL
if ! git remote | grep -q "^upstream$"; then
  echo "No 'upstream' remote found."
  read -p "Enter upstream repository URL (e.g. https://github.com/original/repo.git): " UPSTREAM_URL
  git remote add upstream "$UPSTREAM_URL"
fi

echo "Fetching latest changes from upstream..."
git fetch upstream

echo "Switching to $BRANCH..."
git checkout "$BRANCH" || exit 1

echo "Merging upstream/$BRANCH into local $BRANCH (no history rewrite, no editor)..."
git merge upstream/"$BRANCH" --no-edit

echo "Fetching origin to check if your fork has commits ahead..."
git fetch origin

echo "Merging origin/$BRANCH as well (to avoid push rejects, no editor)..."
git merge origin/"$BRANCH" --no-edit

echo "Pushing merged branch to your fork (origin)..."
git push origin "$BRANCH"

echo "Fork and local branch are now fully synced."
