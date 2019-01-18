namespace :data do
  desc 'Placeholder for moving data from prod to qa - solr - TODO'
  task :solr_data do
    run_locally do #what does this mean
      roles(:web).each do |host| #i wish i could get at the hosts easier, needs more research
        #execute :rsync, '-avzr', "/foobar", "#{host.user}@#{host.hostname}:/foobar"
        if host.level == :prod
            puts "move solr related files to qa"
            puts "do some sort of export?"
        end
        if host.level == :qa
            puts "do nothing"
        end
      end
      roles(:web).each do |host| 
       
       if host.level == :prod
           puts "do nothing"
       end
       if host.level == :qa
           puts "delete indexs and everything"
           puts "ensure there is still the same solr core"
           puts "restart jetty"
           puts "do whats next somehow with curl?"
           puts "Go to http://localhost:8983/solr/LuckBox/admin/dataimport.jsp?handler=/dataimport"
           puts "1 : click on Reload-config"
           puts "2 : click on Full-import"
           puts "3 : done when status becomes “idle” (by clicking on Status)."
                
        end
      end
    end
  end
end