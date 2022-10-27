## BETWORK 
Betwork is a sports betting application built for sports enthusiasts who are tired of losing money to the house. Betwork allows you to ditch the bookie and makes sports betting enjoyable once again!

### Setup 

Clone this repo using the following command:

```
git clone https://github.com/Betwork/betwork.git 
cd betwork 
```
Then use bundler to install all dependencies 

```
bundle install
```

Run Migrations:

```
rake db:migrate
```

Run rails using

```
rails server
```

### Test Data 
To get mock data, run the following commands
```
rake fill:data
```

This will create records with values from faker & populator gems. Also here are the test user credentials:

* email: test@betwork.com
* password: password