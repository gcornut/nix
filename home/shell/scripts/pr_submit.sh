#!/bin/bash -e -x

if gh pr view > /dev/null 2>&1; then
    echo -e PR exists "\n"
    git psf
    echo
    gh pr view --json title,url,labels | jq -r \
'. + { labels: (if (.labels | length) <= 0 then "" else "\u001b[1mLabels: \u001b[0m"+(.labels|map(.name)|join(", ")) end) } |
"\u001b[1m\(.title)\u001b[0m
\(.url)
\(.labels)"'
else
    parent=$(gt parent) # Fails if branch is not tracked
    echo -e PR does not exist "\n"
    gh pr create -d --base ${parent}
fi

# TODO submit stack