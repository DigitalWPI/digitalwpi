namespace :data do
  desc 'placeholder for moving data between Prod and QA - Fedora commons - TODO'
  task :pull_fedora_data do
    on roles(:db) do
      execute(:echo, "$RELATED_DATA_SERVER")
      execute(:echo, "$FCDB_USER")
      execute("pg_dump -C -U $FCDB_USER -W $FEDORA_PASSWORD fcrepo | psql -h hyrax-qa.wpi.edu -U $FCDB_USER -W $FEDORA_PASSWORD fcrepo") # get fedora psql data
    end
  end
end