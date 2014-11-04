#!/bin/bash
set -e # Enable automatic exit on error

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd $ROOT # Make sure we start from the same place every time

echo "Running $1 in $(pwd)"

case "$1" in
  before_install )
    # Show this source file
    cat "${BASH_SOURCE[0]}"
    cd ../

    echo "Installing SDK dependencies"
    sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y
    sudo add-apt-repository ppa:kalakris/cmake -y
    sudo apt-get update -qq
    sudo apt-get install -qq gcc-4.8 g++-4.8 cmake # python2.7 nodejs default-jre
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 20
    sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 20
    sudo update-alternatives --set gcc /usr/bin/gcc-4.8
    sudo update-alternatives --set g++ /usr/bin/g++-4.8
    echo

    echo "Installing WebDriver dependencies"
    sudo pip install selenium sauceclient
    echo

    echo "Downloading and extracting the SDK"
    wget https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-portable.tar.gz
    tar -xzvf emsdk-portable.tar.gz
    echo
    ;;
  install )
    echo "Initializing the SDK"
    cd ../emsdk_portable

    gcc --version
    printenv | grep -v "SAUCE" | sort
    echo

    ./emsdk update && echo
    ./emsdk install sdk-incoming-64bit && echo
    ./emsdk activate sdk-incoming-64bit && echo

    echo "Switch to the commit currently tested by Travis"
    cd emscripten/incoming
    git remote add travis-remote $ROOT/..
    git checkout -b travis-incoming --track travis-remote/incoming
    ;;
  before_script )
    emcc -v
    ;;
  script )
    set +e # Disable automatic exit on error, like Travis does for tests
    export EMSCRIPTEN_BROWSER=$ROOT/tests/webdriver.py
    python tests/runner.py sanity
    python tests/runner.py # main
    python tests/runner.py other
    python tests/runner.py browser
    python tests/runner.py sockets
    ;;
  after_success )
    ;;
  after_failure )
    ;;
  after_script )
    ;;
esac
