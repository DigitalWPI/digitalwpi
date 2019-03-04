namespace :deploy do
	desc "Performs first deploy to server"
	task :with_batch_loader do
		after "deploy:updated", "deploy:add_batch_loader"
		invoke "deploy"
	end
	desc "frist deploy + asset precompilation"
	task :with_assets do
		after "deploy:updated", "deploy:asset_precompile"
		invoke "deploy"
	end
	desc "frist deploy + bundle install (to vendor/bundle)"
	task :with_bundle_install do
		after "deploy:updated", "deploy:bundle_install"
		invoke "deploy"
	end
	desc "frist deploy"
	task :with_all do
		after "deploy:updated", "deploy:add_batch_loader"
		after "deploy:add_batch_loader", "deploy:bundle_install"
		after "deploy:bundle_install", "deploy:asset_precompile"
		after "deploy:asset_precompile", "deploy:migrate"
		invoke "deploy"
	end
	desc "runs rm and git clone for batch_loader, because cap doesnt support submodules"
	task :add_batch_loader do
		on roles(:app) do
			within release_path do #release_path is current path to our released project on the remote surver. 
				execute(:rm, "-rf", :batch_loader)
				execute(:git,:clone,"https://github.com/DigitalWPI/batch-loader.git")
			end
		end			
	end
	desc "rails assets:precompile"
	task :asset_precompile do
		on roles(:app) do
			within release_path do #release_path is current path to our released project on the remote surver. 
				with rails_env: fetch(:rails_env) do
					execute(:rails,"assets:precompile")
					# execute(:rails,"db:migrate")
				end
			end
		end			
	end
	desc "do: bundle install --path vendor/bundle"
	task :bundle_install do
		on roles(:app) do
			within release_path do #release_path is current path to our released project on the remote surver. 
				execute(:bundle, :install, "--path vendor/bundle")
				# execute(:rails,"db:migrate")
			end
		end			
	end
	desc "rails db:migrate"
	task :migrate do
		on roles(:app) do
			within release_path do #release_path is current path to our released project on the remote surver. 
				with rails_env: fetch(:rails_env) do
					execute(:rails,"db:migrate")
					execute(:rails,"c")
				end
			end
		end			
	end
end
