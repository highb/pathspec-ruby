#!/usr/bin/env ruby

require 'optionparser'
require 'pathspec'
options = { 
  spec_type: :git,
  spec_filename: '.gitignore'
}

optparser = OptionParser.new do |opts|
  opts.banner = %q{Usage: pathspec-rb [options] [subcommand] [path]
Subcommands:
  specs_match: Finds all specs matching path.
  tree: Finds all files under path matching the spec.
  match: Checks if the path matches any spec.

EXIT STATUS:
  0   Matches found.
  1   No matches found.
  >1  An error occured.

}
  opts.on('-f', '--file FILENAME', String, 
          'A spec file to load. Default: .gitignore') do |filename|
    unless File.readable?(filename)
      puts "Error: I couldn't read #{filename}"
      exit 2
    end

    options[:spec_filename] = filename
  end
  opts.on('-t', '--type [git|regex]', %i[git regex],
          'Spec file type in FILENAME. Default: git. Available: git and regex.') do |type|
    options[:spec_type] = type
  end
  opts.on('-v', '--verbose', 'Only output if there are matches.') do |verbose|
    options[:verbose] = true
  end
end

optsparsed = optparser.parse!

command = ARGV[0]
path = ARGV[1]
if path
  spec = PathSpec.from_filename(options[:spec_filename], options[:spec_type])
else
  puts optparser.help
  exit 2
end

case command
when 'specs_match'
  if spec.match(path)
    if options[:verbose]
      puts "#{path} matches the following specs from #{options[:spec_filename]}:"
    end
    puts spec.specs_matching(path)
  else
    if options[:verbose]
      puts "#{path} does not match any specs from #{options[:spec_filename]}"
    end
    exit 1
  end
when 'tree'
  tree_matches = spec.match_tree(path)
  if tree_matches.size > 0
    if options[:verbose]
      puts "Files in #{path} that match #{options[:spec_filename]}"
    end
    puts tree_matches
  else
    if options[:verbose]
      puts "No file in #{path} matched #{options[:spec_filename]}"
    end
    exit 1
  end
when 'match', ''
  if spec.match(path)
    if options[:verbose]
      puts "#{path} matches a spec in #{options[:spec_filename]}"
    end
  else
    if options[:verbose]
      puts "#{path} does not match any specs in #{options[:spec_filename]}"
    end
    exit 1
  end
else
  puts "Unknown sub-command #{command}."
  puts optparser.help
  exit 2
end
