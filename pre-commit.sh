#!/bin/sh

SOURCE=cv.tex
TARGET=README.md
VERBOSENESS=1

# Check if SOURCE file has staged changes
if ! git diff --name-only --cached | grep -q $SOURCE;
then
    # SOURCE is not staged, so there is nothing to do
    if [ "$VERBOSENESS" -ge 2 ];
    then
        echo "Source file $SOURCE is not staged, so there is nothing to do.";
    fi
    exit 0;
fi

# Check if TARGET file has staged changes
if git diff --name-only --cached | grep -q $TARGET;
then
    # SOURCE is not staged, so there is nothing to do
    echo "Target file $TARGET has staged changes, so we can't proceed.";
    echo "You can only stage changes to one of $SOURCE and $TARGET at once.";
    exit 1;
fi

# Check if SOURCE or TARGET file has unstaged changes
NEED_STASH=$(git ls-files -m | grep -q -e $SOURCE -e $TARGET)
# If so, we need to temporarily stash changes not on the working index
if $NEED_STASH;
then
    git stash -k -q
    if [ "$VERBOSENESS" -ge 1 ];
    then
        echo "Stashed unstaged changes before working on pre-commit hook.";
    fi
fi

if [ "$VERBOSENESS" -ge 2 ];
then
    echo "Pre-commit hook has work to do.";
fi

# Generate target from source
pandoc -s "$SOURCE" -o "$TARGET" -t markdown_strict --normalize
# Stage the generated changes
git add $TARGET

if [ "$VERBOSENESS" -ge 1 ];
then
    echo "Regenerated and staged $TARGET based on staged changes to $SOURCE.";
fi

# Pop back from the temporary stash
if $NEED_STASH;
then
    git stash pop -q
    if [ "$VERBOSENESS" -ge 1 ];
    then
        echo "Popped the stash back again.";
    fi
fi

# Exit with success
exit 0;
