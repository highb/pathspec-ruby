require 'pathspec/spec'

class RegexSpec < Spec
  def initialize(regex)

    @regex = Regexp.new regex if regex
  end

  def match(path)
    @regex.match(path) if @regex
  end
end
