namespace :deploy do
	desc "Performs first deploy to server"
	task :with_batch_loader do
		after "deploy:updated", "deploy:add_batch_loader"
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
end