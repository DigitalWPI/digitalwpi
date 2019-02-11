namespace :deploy do
	desc "Performs first deploy to server"
	task :initial do
		after "deploy:log_revision", "deploy:initial:copy_solr_config"
		after "deploy:initial:copy_solr_config", "deploy:initial:restart_solr"
		after "deploy:initial:restart_solr", "deploy:initial:restart_fedora"

		after "deploy:initial:restart_fedora", "deploy:initial:bundle_install"
		after "deploy:initial:bundle_install", "deploy:initial:restart_passenger"
		invoke "deploy"
	end
	namespace :initial do 
		desc "copy solr config stuff over to other server"
		task :copy_solr_config do
			on roles(:app) do
				within release_path do #release_path is current path to our released project on the remote surver. 
					execute("COPY STUFF")
					execute("COPY STUFF")
				end
			end
		end
		desc "start/restart solr"
		task :restart_solr do
			on roles(:app) do
				within release_path do #release_path is current path to our released project on the remote surver. 
					execute("COPY STUFF")
					execute("COPY STUFF")
				end
			end
		end
		desc "start/restart fedora"
		task :restart_fedora do
			on roles(:app) do
				within release_path do #release_path is current path to our released project on the remote surver. 
					execute("COPY STUFF")
					execute("COPY STUFF")
				end
			end
		end
		desc "start/restart passenger"
		task :restart_passenger do
			on roles(:app) do
				within release_path do #release_path is current path to our released project on the remote surver. 
					execute("COPY STUFF")
					execute("COPY STUFF")
				end
			end
		end
		desc "install all the gems"
		task :bundle_install do
			on roles(:app) do
				within release_path do #release_path is current path to our released project on the remote surver. 
					execute("COPY STUFF")
					execute("COPY STUFF")
				end
			end
		end
	end
end