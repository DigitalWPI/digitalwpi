
namespace :debug do
  desc 'Print ENV variables'
  task :env do
    on roles(:app), in: :sequence, wait: 5 do
      execute(:printenv)
      execute(:env)
    end
  end
end