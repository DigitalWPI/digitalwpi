require 'optparse'

namespace :wpi do
  desc 'Replace tiff files with jpg files in works. usage: wpi:replace_tiff_with_jpg -- --input_csv=FPATH'
  task replace_tiff_with_jpg: :environment do
    options = {}

    op = OptionParser.new
    op.banner = "Usage: rake ingest -- --input_csv=FPATH"
    op.on('-i FPATH', '--input_csv=FPATH', 'Path to input csv file') { |fpath| options[:fpath] = fpath }
    args = op.order!(ARGV) {}
    op.parse!(args)

    raise OptionParser::MissingArgument if options[:fpath].nil?

    a = AddJpegToWorks.new(options[:fpath])
    a.add_from_csv
  end
end
