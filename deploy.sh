
#!/bin/sh

# Ask the user for enter commit message
export LANG=C.UTF-8
read -p 'Commit message: ' msg

# If a command fails then the deploy stops
set -e

printf "\033[0;32mDeploying updates to GitHub...\033[0m\n"

# Build the project.
hugo # if using a theme, replace with `hugo -t <YOURTHEME>`

# Go To Public folder
cd public

# Add changes to git.
git add .

# Commit changes.

git commit -m "$msg"

# Push source and build repos.
git push origin master
