ensure you have the following databases in your mysql instance
+ hyraxdb     
+ hyraxdb_test
you can create these with 
`create database hyraxdb;`
`create database hyraxdb_test;`
`CREATE USER 'rails'@'%' IDENTIFIED BY 'YOUR_PASS';`
then run the following to give rails th access it needs
`GRANT ALL ON hyraxdb.* to 'rails'@'%';`
`GRANT ALL ON hyraxdb_test.* to 'rails'@'%';`
then in your ~/.bash_profile or other dot file of your choosing put
`export MYSQL_DB_HOST='YOUR.IP.HERE'`
`export MYSQL_RAILS_PASS='YOUR_PASS'`
if you want to run this imediatly just do source ~/.bash_profile (or other or export them in your terminal)