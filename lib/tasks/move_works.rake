# frozen_string_literal: true
require 'fileutils'
require 'json'
require 'optparse'
namespace :wpi do
  desc "Move works to collection"
  task move_to_col: :environment do |_t, args|
    options = {}

    op = OptionParser.new
    op.banner = "Usage: bundle exec rake wpi:move_to_col -- --worktype WORKTYPE --collection=COLLECTION (optional)"
    op.on('-wt WORKTYPE', '--worktype=WORKTYPE', 'string representing hyrax worktype, ie worktype') { |worktype| options[:worktype] = worktype }
    op.on('-cl COLLECTION', '--collection=COLLECTION', 'an id of a collection to add these works to') { |collectionid| options[:collectionid] = collectionid }
    op.on('-wh WHERE_STATEMENT_ARGS', '--where=WHERE_STATEMENT_ARGS', 'an id of a collection to add these works to') { |select| options[:select] = select } 

    # return `ARGV` with the intended arguments
    args = op.order!(ARGV) {}
    op.parse!(args)

    raise OptionParser::MissingArgument if options[:collectionid].nil?
    raise OptionParser::MissingArgument if options[:worktype].nil?
    raise OptionParser::MissingArgument if options[:select].nil?
    begin
      worktype = eval(options[:worktype])
    rescue
      raise InvalidWorkType, "An invalid worktype was given #{options[:worktype]} was not okay"
    end
    
    all_specified_works = worktype.where(eval(options[:select])) #the select is something like '{:resource_type => "thesis"}'
    col = Collection.find(options[:collectionid])
    all_specified_works.each do |work|
      if work.member_of_collections.empty?
        work.member_of_collections = [col]
      end
    end
  end
end