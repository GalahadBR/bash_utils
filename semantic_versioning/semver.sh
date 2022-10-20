#!/bin/sh -x
function version_check { echo "$@" | awk -F. '{ printf("%d%03d%03d\n", $1,$2,$3); }'; }

VERSION=$(jq -r '.version' package.json)
git config --global --add safe.directory "*"
GIT_LAST_COMMIT=$(git rev-list --no-merges -n 2 HEAD | tail -1)
GIT_VERSION=$(git show ${GIT_LAST_COMMIT}:package.json | jq -r '.version')

if [ -z "${VERSION}" ] || [ -z "${GIT_VERSION}" ]; then
  BUMP="failed"
  echo ${BUMP}
  exit 0
else
  echo ${VERSION} ${GIT_VERSION} | awk -F. '{print $1,$2,$3,$4,$5,$6}' |
    while read a_major a_minor a_patch b_major b_minor b_patch; do

      if [[ $(version_check ${VERSION}) -gt $(version_check ${GIT_VERSION}) && ${a_major} -gt ${b_major} ]]; then
        BUMP="major"
        echo ${BUMP}

      elif [[ $(version_check ${VERSION}) -gt $(version_check ${GIT_VERSION}) && ${a_minor} -gt ${b_minor} ]]; then
        BUMP="minor"
        echo ${BUMP}

      elif [[ $(version_check ${VERSION}) -gt $(version_check ${GIT_VERSION}) && ${a_patch} -gt ${b_patch} ]]; then
        BUMP="patch"
        echo ${BUMP}

      else
        BUMP=false
        echo ${BUMP}
      fi
    done
fi
