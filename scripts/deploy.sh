#!/usr/bin/env bash

# This script is executed by Travis CI when a PR is merged (i.e. in the `deploy` step).
set -ex

function initialize {
  if [ -z "$TLDRHOME" ]; then
    export TLDRHOME=${TRAVIS_BUILD_DIR:-$(pwd)}
  fi
  
  export TLDR_ARCHIVE="tldr.zip"
  export SITE_HOME="$HOME/site"
  export SITE_REPO_SLUG="circleci-test-ix/tldr-pages.github.io"

  # Configure git.
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
  git config --global push.default simple
  git config --global diff.zip.textconv "unzip -c -a"
}

function upload_assets {
  git clone --quiet --depth 1 git@github.com:${SITE_REPO_SLUG}.git "$SITE_HOME"
  mkdir -p "$SITE_HOME/assets/"
  mv -f "$TLDR_ARCHIVE" "$SITE_HOME/assets/"
  cp -f "$TLDRHOME/index.json" "$SITE_HOME/assets/"

  cd "$SITE_HOME"
  git add -A
  git commit -m "[TravisCI] uploaded assets after commits ${TRAVIS_COMMIT_RANGE}"
  git push -q

  echo "Assets (pages archive, index) deployed to static site."
}

###################################
# MAIN
###################################

initialize
upload_assets
