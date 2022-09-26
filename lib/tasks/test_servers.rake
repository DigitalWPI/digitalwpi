FEDORA_PID_FILE = 'tmp/.fedora-test.pid'
SOLR_PID_FILE = 'tmp/.solr-test.pid'
MINTER_FILE = 'tmp/minter'

namespace :test do
  namespace :servers do

    desc "Load the solr options and solr instance"
    task :environment do
      abort "ERROR: must be run with RAILS_ENV=test (currently: #{ENV['RAILS_ENV']})" unless ENV['RAILS_ENV'] == 'test'

      SolrWrapper.default_instance_options =  { config: 'config/solr_wrapper_test.yml' }
      @solr_instance = SolrWrapper.default_instance
      @fcrepo_instance = FcrepoWrapper.default_instance(config: 'config/fcrepo_wrapper_test.yml')
    end

    desc 'Starts a test Solr and Fedora instance for running cucumber tests'
    task :start => :environment do
      abort "WARNING: Solr-test is already running; run \"rake test:servers:stop\" to stop it" if File.exists?(SOLR_PID_FILE)
      abort "WARNING: Fedora-test is already running; run \"rake test:servers:stop\" to stop it" if File.exists?(FEDORA_PID_FILE)

      # clean out any old solr files
      @solr_instance.remove_instance_dir!
      @solr_instance.extract_and_configure

      # start solr
      @solr_instance.start
      # create the core - a bit of a bodge is required to get the correct collection options
      collection_options = HashWithIndifferentAccess.new(@solr_instance.config.options[:collection].except(:name))
      @solr_instance.create(collection_options)
      File.write(SOLR_PID_FILE, @solr_instance.pid)

      # start fedora
      @fcrepo_instance.remove_instance_dir!
      @fcrepo_instance.start
      File.write(FEDORA_PID_FILE, @fcrepo_instance.pid)
    end

    task :stop => :environment do
      # kill fedora and clean up
      if File.exists?(FEDORA_PID_FILE)
        # NB: we cannot use @fcrepo_instance.stop here as the @instance does not know its PID, so kill in the conventional way instead
        Process.kill 'HUP', File.read(FEDORA_PID_FILE).to_i
        File.delete(FEDORA_PID_FILE)
        sleep(0.5)
        @fcrepo_instance.remove_instance_dir!
      end

      # stop solr and clean up
      if File.exists?(SOLR_PID_FILE)
        @solr_instance.stop
        File.delete(SOLR_PID_FILE)
        @solr_instance.remove_instance_dir!
      end

      # delete the test minter file
      File.delete(MINTER_FILE) if File.exists?(MINTER_FILE)
    end
  end
end
