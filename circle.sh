#!/bin/bash
set -ex
set -o pipefail

CIRCLEUTIL_TAG="v1.37"

export CIRCLE_ARTIFACTS="${CIRCLE_ARTIFACTS-/tmp}"
export BASE_DIR="$HOME/collectd"

# Cache phase of circleci
function do_cache() {
  echo "BASE_DIR IS $BASE_DIR"

  [ ! -d "$HOME/circleutil" ] && git clone https://github.com/signalfx/circleutil.git "$HOME/circleutil"
  (
    cd "$HOME/circleutil"
    git fetch -a -v
    git fetch --tags
    git reset --hard $CIRCLEUTIL_TAG
  )
  . "$HOME/circleutil/scripts/common.sh"

  export SFX_BUILD_PLATFORM="$1"
  export DISTRIBUTION="$2"
  export SFX_BUILD_DOCKER="$3"
  if [ "$SFX_BUILD_DOCKER" == "none" ]; then
    export JOB_NAME=cr_"$CIRCLE_PROJECT_REPONAME"_build_"$SFX_BUILD_PLATFORM"
  else
    export JOB_NAME=cr-"$CIRCLE_PROJECT_REPONAME"-rpm-"$DISTRIBUTION"
  fi

  echo "SFX_BUILD_PLATFORM is $SFX_BUILD_PLATFORM"
  echo "DISTRIBUTION is $DISTRIBUTION"
  echo "SFX_BUILD_DOCKER is $SFX_BUILD_DOCKER"
  if [ "$SFX_BUILD_DOCKER" == "none" ]; then
    clone_repo git@github.com:signalfx/collectd-build-ubuntu.git "$BASE_DIR"/collectd-build-ubuntu origin/testci
    "$BASE_DIR"/collectd-build-ubuntu/build-collectd/sfx_scripts/jenkins-build
  else
    clone_repo git@github.com:signalfx/collectd-build-rpm.git "$BASE_DIR"/collectd-build-rpm origin/testc
    "$BASE_DIR"/collectd-build-rpm/build-collectd/build/jenkins-build  
  fi
  
}

# Test phase of circleci
function do_test() {

  . "$HOME/circleutil/scripts/common.sh"
  echo "no testing for now!!!"
}

# Deploy phase of circleci
function do_deploy() {

  . "$HOME/circleutil/scripts/common.sh"
  echo "no deploy for now!!!"
}

function do_all() {
  do_cache "$2" "$3" "$4"
  do_test
  do_deploy
}

case "$1" in
  cache)
    do_cache "$2" "$3" "$4"
    ;;
  test)
    do_test
    ;;
  deploy)
    do_deploy
    ;;
  all)
    do_all "$2" "$3" "$4"
    ;;
  *)
  echo "Usage: $0 {cache|test|deploy|all}"
    exit 1
    ;;
esac
