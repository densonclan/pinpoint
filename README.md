[ ![Codeship Status for srclab/pinpoint](https://codeship.com/projects/2a1f6e30-98f1-0132-429b-066a8b8c9dee/status?branch=master)](https://codeship.com/projects/63517)

## General

This is the repository that manages CI & CD. Once your code has been committed to master locally, and pushed to master in **this** repo, it will automatically be deployed to production.

Never SSH onto the production box to perform deployment commands. With CI & CD this is almost never required. All deployment is handled internally.

Never run rake tasks or rails console against the production environment. There is never a case when this is required.

Never make changes directly to the database via a GUI. This can disrupt the history and these updates can always be made via the CMS.

## CI & CD

https://codeship.com/projects/63517

## Server

Location of the folder `/var/www/pinpointlms/current`

1. To run the rails console on the server, run the commands:
    `$ cd /var/www/pinpointlms/current`
    `$ RAILS_ENV=production rails console`

2. To restart rails server, run the commands:
    `$ cd /var/www/pinpointlms/current`
    `$ sudo touch tmp/restart.txt`

3. To back up the database:
    `$ pg_dump pinpoint_production -h localhost -U pinpoint > FILENAME.dump`
    then the password: `<database password>`

## Development

1. On your machine, you need to have installed the following:
    - Git (Version Control software) version 1.7 upwards
    - RVM (Ruby Version Manager) - only needed on a Mac computer
    - Ruby 1.9.3p374 (to install through RVM run the command: `rvm install 1.9.3p374` and `rvm use 1.9.3p374` )

2. Clone source code of the application:
    `$ git clone ssh://git@bitbucket.org/pinpoint/pinpoint.git`
    `$ cd pinpoint`
    `$ bundle install`

    Command `bundle install` will install all missing dependencies on your machine needed to develop for pinpoint

And you're ready to develop,

3. Adding and commiting changes:
    Every change of the code you would like to deploy,
    has to be added and commited to the version control, this keeps the workflow nice and tidy.

    `$ git add .`
    `$ git commit -m 'Describe your change in a quick message'`
    `$ git push origin master`

Command `git push` will push it to the bitbucket repository

4. Before deploying code, remember to always test the code against the application tests.
    It is important to run tests as it makes sure everything works correctly, to run tests, enter command:
    `$ rake spec`


## Development with vagrant

1. Install vagrant and VirtualBox

2. Change the username and password to developer/password (this is created by ) in database.yml

3. Start virtual machine by running following command (it will take a while)
    `vagrant up`

4. Go in virtual machine and cd into project folder
    `vagrant ssh`
    `cd pinpoint`

5. Run folloing commands to setup project
    `bundle install`
    `rake db:create`

6. Import data from dump
    `psql pinpoint -U developer -W < db/backups/sourcelab_backup.sql`

7. Run rails migration
    `bundle exec rake db:migrate`

8. Start rails server and access it via http://localhost:3001
    `rails s -p 3001`

## Deployment from local

1. Go to deploy folder
    `cd deploy`
2. Run bundle install
    `bundle install`
3. To deploy run following command to deploy to production
    `cap production deploy`

### Deployment with codeship

CodeShip will deploy commits to the PRODUCTION branch to the PRODUCTION environmemt.
So, to trigger this it is recommended to create a tag in the master branch

    > git checkout master
    > git pull
    > git tag -am 'some useful text' v1.0.X
    > git checkout production
    > git merge v1.0.X
    > git push origin production

To determine what X should be, simply list the current tags

    > git tag

Using a tag ensures you have a persistent record of the point that was actually
deployed to production.


## Provisioning a fresh box

1. User Ubuntu trusty image to setup the app and database.
2. To prepare the box for provisioning run the shell script puppet/bootstrap.sh
3. Add your public key to the box to avoid entering password too many times
4. Run the rake task 'rake provision:app[<ip of the box>]'. This will take a while since this will install everything for the app from scratch.
4. Once this is complete the box is provisioned with all the packages. We need to deploy the app now. The script creates app user.
5. Add public key to app user as well. Also change the database.yml on the box to have correct creds.
6. All set now, just change ip of the box in deploy/config/deploy/production.rb for capistrano to know the right server and run 'cap production deploy'
7. Thats all. If all the settings are correct then the app should be up and running.

## Maintenance

1. Webmin gives you access to postgres, just login with root details on `http://192.168.254.5:10000`

2. If a user gets a page saying 'Something went wrong' and you would like to see what happened, you can access the logs of the application
    All logs are located in :
    `$ cd /var/www/pinpointlms/current/log/`

    Running application log: `/var/www/pinpointlms/current/log/production.log`
    Import logs: `/var/www/pinpointlms/current/log/Import_XXXXXXX.log`
    Export logs: `/var/www/pinpointlms/current/log/Export_XXXXXXX.log`

## Backup

1. Server is backing up the database on a daily basis at 1am on Rackspace CloudFiles in backup/database. Each backup is a Tar compressed archive.
2. Documents, Logotypes and Any user files are synced up every day at 1am on Rackspace CloudFiles in backup/documents
