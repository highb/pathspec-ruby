$LOAD_PATH.unshift( File.join( File.dirname(__FILE__), '../lib' ) )
require 'pathspec/gitignorespec'

class PathSpec
  attr_reader :specs

  def initialize
    puts "Initialized pathspec"
    @specs = []
  end

  # Check if a path or Enumerable of paths matches the specs described
  # Returns boolean if a path
  # Returns matched paths found if Enumberable, or nil if none matched
  def match(path)
    false
  end

  def inclusive?
    false
  end

  # Check if any files in a given directory or subdirectories match the specs
  # Returns matched paths or nil if no paths matched
  def match_tree(path)
    []
  end

  # Generate specs from a file, such as a .gitignore
  def from_file(file, type=:git)
  end

  # Generate specs from lines of text
  def from_lines(lines, type=:git)
  end
end
