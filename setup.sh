#!/bin/sh
brew update
brew upgrade
brew install shared-mime-info
brew install postgresql
git fetch
git stash
git checkout proj-launch
git pull
bundle install
bundle update
rake db:drop
rake db:migrate
rake fill:data
rails server
