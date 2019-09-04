#! /bin/sh

if [[ "$1" == "before_install" ]]; then
  gem update --system
  gem install bundler
  exit $?
elif [[ "$1" == "install" ]]; then
  bundle install
  exit $?
elif [[ "$1" == "build" ]]; then
  bundle exec fastlane build_for_testing
  exit $?
else
  exit 1
fi
