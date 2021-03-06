#!/bin/bash -e

export RES_REPO_NAME=$1

export RES_REPO_UP=$(shipctl to_uppercase $RES_REPO_NAME)
export RES_REPO_PATH=$(eval echo "$"$RES_REPO_UP"_PATH")
export RES_REPO_PULL_REQUEST=$(eval echo "$"$RES_REPO_UP"_PULL_REQUEST")

run_jshint() {
  if [ "$(which jshint)" == "" ]; then
    echo "Installing jshint"
    npm install -g jshint
  else
    echo "jshint found. Skipping installation."
  fi

  echo "Extracting before and after SHAs for this PR"
  export BEFORE=$(shipctl get_json_value $RES_REPO_PATH/version.json version.propertyBag.shaData.beforeCommitSha)
  export AFTER=$(shipctl get_json_value $RES_REPO_PATH/version.json version.propertyBag.shaData.commitSha)

  echo "Getting list of JS files that changed between commits $BEFORE and $AFTER"
  pushd $RES_REPO_PATH/gitRepo
  export CHANGED_JS_FILES=$(git diff --name-only $BEFORE...$AFTER | grep ".js$")

  if [ "$CHANGED_JS_FILES" != "" ]; then
    echo "Running jshint against changed JS files"
    jshint $CHANGED_JS_FILES
  else
    echo "No JS files changed between these commits"
  fi
  
  popd
}

if [ "$RES_REPO_PULL_REQUEST" == false ]; then
  echo "This job was not triggered by a pull request. Exiting early"
else
  run_jshint
fi
