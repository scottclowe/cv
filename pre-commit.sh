#!/bin/sh

SOURCE=cv.tex
TARGET=README.md

# Check if SOURCE file has staged changes
if ! git diff --name-only --cached | grep -q $SOURCE;
then
    # SOURCE is not staged, so there is nothing to do
    echo "Source file $SOURCE is not staged, so you're fine."
    exit 0;
fi

# Check if TARGET file has unstaged changes
if git ls-files -m | grep -q $TARGET;
then
    echo "Target file $TARGET has unstaged changes."
    echo "You need to fix this before committing changes to $SOURCE."
    exit 1;
fi

# Check if SOURCE file has unstaged changes
NEED_STASH=git ls-files -m | grep -q $SOURCE
if $NEED_STASH
then
    echo "Had to stash before working on pre-commit hook"
    git stash -k -q
fi

echo "Pre-commit hook has work to do..."

# Do the work
pandoc -s "$SOURCE" -o "$TARGET" -t markdown_strict --normalize
git add $TARGET

echo "I've regenerated $TARGET and staged it for you."

if $NEED_STASH
then
    git stash pop -q
    echo "Popped the stash back again"
fi

# Exit with success
exit 0;
