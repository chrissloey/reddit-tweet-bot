#!/usr/bin/env bash
# Fix for Gemfiles being touched by the CI and causing a cache miss

# Nasty hack: Because we get a freshly restored repo, timestamps do not
# correspond any more to when the file was last changed. To rectify this,
# first set everything to a timestamp in the past and then update the
# timestamp for all git-tracked files based on their last committed change.
find . -exec touch -t 201401010000 {} \;
for x in $(git ls-tree --full-tree --name-only -r HEAD); do touch -t $(date -d "$(git log -1 --format=%ci "${x}")" +%y%m%d%H%M.%S) "${x}"; done
