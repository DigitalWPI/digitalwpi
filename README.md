## Installing the application

Install system dependencies

* Setup your workstation for Rails development first
* Solr version >= 5.x (tested up to 7.0.0)
* Fedora Commons digital repository version >= 4.5.1 (tested up to 4.7.5)
* A SQL RDBMS (MySQL, PostgreSQL), though note that SQLite will be used by default if you're looking to get up and running quickly
  * libmysqlclient-dev (if running MySQL as RDBMS)
  * libsqlite3-dev (if running SQLite as RDBMS)
* Redis, a key-value store
* ImageMagick with JPEG-2000 support
* FITS version 1.0.x ([1.0.5](http://projects.iq.harvard.edu/files/fits/files/fits-1.0.5.zip) is known to be good)
* LibreOffice
* ffmpeg

1. Clone this repository: `git clone https://github.com/DigitalWPI/digitalwpi ./path/to/local`
    * **Note:** Solr will not run properly if there are spaces in any of the directory names above it <br />(e.g. /user/my apps/digitalwpi/)
1. Change to the application's directory: e.g. `cd ./path/to/local`
1. Make sure you are on the develop branch: `git checkout master`
1. Install bundler (if needed): `gem install bundler`
1. Run bundler: `bundle install`
1. Start fedora: ```fcrepo_wrapper -p 8984```
1. Start solr: ```solr_wrapper -d solr/config/ --collection_name hydra-development```
1. Start redis: ```redis-server```
1. Run the database migrations: `bundle exec rake db:migrate`
1. Start the rails server: `rails server`
1. Visit the site at [http://localhost:3000] (http://localhost:3000)
1. Create default admin set: ```bin/rails hyrax:default_admin_set:create```
1. Load workflows: ```bin/rails hyrax:workflow:load```
    * Creating default admin set should also load the default workflow. You can load, any additional workflows defined, using this command.
1. Assigning admin role to user from `rails console`:
    * ```admin = Role.create(name: "admin")```
    * ```admin.users << User.find_by_user_key( "your_admin_users_email@fake.email.org" )```
    * ```admin.save```
    * Read [more](https://github.com/samvera/hyrax/wiki/Making-Admin-Users-in-Hyrax).

# Project Samvera
This software has been developed by and is brought to you by the Samvera community. Learn more at the
[Samvera website](http://projecthydra.org)

![Samvera Logo](https://wiki.duraspace.org/download/thumbnails/87459292/samvera-fall-font2-200w.png?version=1&modificationDate=1498550535816&api=v2)
