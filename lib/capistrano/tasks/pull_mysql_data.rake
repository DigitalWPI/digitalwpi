namespace :data do
  desc 'placeholder for moving data between Prod and QA - MYSQL - TODO'
  task :pull_mysql_data do
    on roles(:db) do
      execute(:echo, "$HYRAX_DATABSE")
      execute(:echo, "$HYRAX_DATABSE_USERNAME")
      if fetch(:pull_data,false)
        execute("mysqldump -u $HYRAX_DATABSE_USERNAME -p $HYRAX_DATABSE_PASSWORD $HYRAX_DATABSE > cap_pull_my.sql") # get mysql
        execute("mysql -u $HYRAX_DATABSE_USERNAME -p $HYRAX_DATABSE_PASSWORD -h #{fetch :prod_server} $HYRAX_DATABSE  < cap_pull_my.sql") #TODO
      else
        raise "Can not pull data becuase :pull_data is set as false or not defined. Are you calling this for qa or test?"
      end
    end
  end
end