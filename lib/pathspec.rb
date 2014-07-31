require 'pathspec/gitignorespec'
require 'pathspec/regexspec'
require 'find'
require 'pathname'

class PathSpec
  attr_reader :specs

  def initialize(lines=nil, type=:git)
    @specs = []

    if lines
      add(lines, type)
    end
  end

  # Check if a path matches the pathspecs described
  # Returns true if there are matches and none are excluded
  # Returns false if there aren't matches or none are included
  def match(path)
    matches = specs_matching(path.to_s)
    !matches.empty? && matches.all? {|m| m.inclusive?}
  end

  def specs_matching(path)
    @specs.select do |spec|
      if spec.match(path)
        spec
      end
    end
  end

  # Check if any files in a given directory or subdirectories match the specs
  # Returns matched paths or nil if no paths matched
  def match_tree(root)
    root = Pathname.new(root)
    slash = Pathname.new('/')
    matching = []

    Find.find(root) do |path|
      path = Pathname.new(path)
      relpath = path.relative_path_from(root).to_s
      relpath += '/' if File.directory? path
      if match(relpath)
        matching << path
      end
    end

    matching
  end

  def match_paths(paths, root='/')
    root = Pathname.new(root)
    slash = Pathname.new('/')
    matching = []

    paths.each do |path|
      path = Pathname.new(path)
      if match(path.relative_path_from(root))
        matching << path
      end
    end

    matching
  end

  # Generate specs from a filename, such as a .gitignore
  def self.from_filename(filename, type=:git)
    self.from_lines(File.open(filename, 'r'))
  end

  def self.from_lines(lines, type=:git)
    inst = self.new lines, type
  end

  # Generate specs from lines of text
  def add(obj, type=:git)
    spec_class = spec_type(type)

    if obj.respond_to?(:each_line)
      obj.each_line do |l|
        spec = spec_class.new(l)

        if !spec.regex.nil? && !spec.inclusive?.nil?
          @specs << spec
        end
      end
    elsif obj.respond_to?(:each)
      obj.each do |l|
        add(l, type)
      end
    else
      @specs << spec_class.new(l)
    end

    self
  end

  def empty?
    @specs.empty?
  end

  def spec_type(type)
    if type == :git
      GitIgnoreSpec
    elsif type == :regex
      RegexSpec
    else
      raise "Unknown spec type #{type}"
    end
  end
end
