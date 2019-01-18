namespace :data do
  desc 'placeholder for moving data between Prod and QA - MYSQL - TODO'
  task :pull_mysql_data do
    on roles(:db) do
      execute(:echo, "$HYRAX_DATABSE")
      execute(:echo, "$HYRAX_DATABSE_USERNAME")
      execute("mysqldump -u $HYRAX_DATABSE_USERNAME -p $HYRAX_DATABSE_PASSWORD $HYRAX_DATABSE > cap_pull_my.sql") # get mysql
      execute("mysql -u $HYRAX_DATABSE_USERNAME -p $HYRAX_DATABSE_PASSWORD -h hyrax-qa.wpi.edu $HYRAX_DATABSE  < cap_pull_my.sql") #TODO
    end
  end
end