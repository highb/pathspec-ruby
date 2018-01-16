require 'pathspec/spec'

class PathSpec
  # Simple regex-based spec
  class RegexSpec < Spec
    def initialize(pattern)
      @pattern = pattern.dup
      @regex = Regexp.compile pattern

      super
    end

    def inclusive?
      true
    end

    def match(path)
      @regex.match(path) if @regex
    end
  end
end
