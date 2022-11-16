#!/bin/sh
if heroku open; then
    echo "App exists"
else
    heroku create --stack heroku-20
fi
git stash
git checkout master
git pull
git push heroku master
heroku run rake db:migrate
heroku run rake fill:data
heroku open