def remote_path_exists?(path)
  if test("[ -f #{path} ]") or test("[ -d #{path} ]")
    return true
  end
  return false
end

namespace :data do
  desc 'placeholder for moving data between Prod and QA - Fedora commons - TODO'
  task :pull_fedora_data do
    on roles(:all) do
      execute(:echo, "$RELATED_DATA_SERVER")
      execute(:echo, "$FCDB_USER")
      execute(:echo,"$FEDORA_HOST")
      if fetch(:pull_data,false)
        # execute("pg_dump -C -U $FCDB_USER -W $FEDORA_PASSWORD fcrepo | psql -h #{fetch :prod_data_server} -U $FCDB_USER -W $FEDORA_PASSWORD fcrepo") # get fedora psql data
        tmp_fcr = "/tmp/fcrepo-exported"
        if remote_path_exists?(tmp_fcr)
          execute(:rm,'-rf', tmp_fcr)
        end
        #wget https://github.com/fcrepo4-labs/fcrepo-import-export.git mvn clean install mv from target to tmp/fcre...
        execute(:mkdir,tmp_fcr)
        import_export_tool_url = "https://github.com/fcrepo4-labs/fcrepo-import-export/releases/download/fcrepo-import-export-0.2.0/fcrepo-import-export-0.2.0.jar"
        path_to_jar = "/tmp/fcrepo-import-export-0.2.0.jar"
        if not remote_path_exists?(path_to_jar)
          execute(:wget,"-q","-O",path_to_jar,import_export_tool_url)
        end
        sha1_url = "https://github.com/fcrepo4-labs/fcrepo-import-export/releases/download/fcrepo-import-export-0.2.0/fcrepo-import-export-0.2.0.jar.sha1"
        execute(:wget,"-q","-O","#{path_to_jar}.sha1", sha1_url)
        calculated_sha1sum = capture(:shasum,path_to_jar).split()[0] #cut out the file name.
        online_sha1sum = capture(:cat,"#{path_to_jar}.sha1").split()[0] #cut out the file name.
        #puts calculated_sha1sum == online_sha1sum
        if calculated_sha1sum == online_sha1sum
          puts "\t\e[32m Calculated sha1sum == Online sha1sum? #{calculated_sha1sum == online_sha1sum}\e[0m"
        end
        puts "\t Exporting fedora data"
        execute(:java, "-jar",path_to_jar,"--mode","export","--resource","http://#{fetch :prod_data_server}:#{fetch :fcrepo_port}/rest","--dir","#{tmp_fcr}","--binaries")
        puts "\t Importing fedora data"
        execute(:java, "-jar",path_to_jar,"--mode","import","--resource","http://130.215.27.148:8984/rest","--dir","#{tmp_fcr}","--binaries","--map","#{fetch :prod_data_server}:#{fetch :fcrepo_port}/rest,http://130.215.27.148:8984/rest")
        #execute(:java, "-jar",path_to_jar,"--mode","import","--resource","$FEDORA_HOST","--dir","#{tmp_fcr}","--binaries","--map","#{fetch :prod_data_server}:#{fetch :fcrepo_port}/rest,$FEDORA_HOST")
      else
        raise "Can not pull data becuase :pull_data is set as false or not defined. Are you calling this for qa or test?"
      end
    end
  end
end
