#!/bin/sh
brew update
brew upgrade
brew install shared-mime-info
brew install postgresql
git fetch
#git checkout master #proj-iter2
git pull
bundle install
bundle update
rake db:drop
rake db:migrate
rake fill:data
RAPIDAPI_API_KEY=0922e8a07dmsh4cacadace93e259p191ebajsn446e95a439bc rails server