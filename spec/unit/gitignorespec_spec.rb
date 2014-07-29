require 'pathspec/gitignorespec'
require 'pry'

describe GitIgnoreSpec do
  # Original specification by http://git-scm.com/docs/gitignore

  # A blank line matches no files, so it can serve as a separator for
  # readability.
  it "does nothing for newlines" do
    spec = GitIgnoreSpec.new "\n"
    expect(spec.match('foo.tmp')).to be_nil
    expect(spec.match(' ')).to be_nil
    expect(spec.inclusive?).to be_nil
  end

  it "does nothing for blank strings" do
    spec = GitIgnoreSpec.new ''
    expect(spec.match('foo.tmp')).to be_nil
    expect(spec.match(' ')).to be_nil
    expect(spec.inclusive?).to be_nil
  end

  # A line starting with # serves as a comment. Put a backslash ("\") in front
  # of the first hash for patterns that begin with a hash.
  it "does nothing for comments" do
    spec = GitIgnoreSpec.new '# this is a gitignore style comment'
    expect(spec.match('foo.tmp')).to be_nil
    expect(spec.match(' ')).to be_nil
    expect(spec.inclusive?).to be_nil
  end

  it "ignores comment char with a slash" do
    spec = GitIgnoreSpec.new '\#averystrangefile'
    expect(spec.match('#averystrangefile')).to be_truthy
    expect(spec.match('foobar')).to be_nil
    expect(spec.inclusive?).to be true
  end

  # Trailing spaces are ignored unless they are quoted with backlash ("\").
  it "ignores trailing spaces" do
    spec = GitIgnoreSpec.new 'foo        '
    expect(spec.match('foo')).to be_truthy
    expect(spec.match('foo        ')).to be_nil
    expect(spec.inclusive?).to be true
  end

  # This is not handled properly yet
  it "does not ignore escaped trailing spaces"

  # An optional prefix "!" which negates the pattern; any matching file excluded
  # by a previous pattern will become included again. It is not possible to
  # re-include a file if a parent directory of that file is excluded. Git
  # doesn't list excluded directories for performance reasons, so any patterns
  # on contained files have no effect, no matter where they are defined. Put a
  # backslash ("\") in front of the first "!" for patterns that begin with a
  # literal "!", for example, "\!important!.txt".
  it "is exclusive of !" do
    spec = GitIgnoreSpec.new '!important.txt'
    expect(spec.match('important.txt')).to be_truthy
    expect(spec.inclusive?).to be false
    expect(spec.match('!important.txt')).to be_nil
  end

  # If the pattern ends with a slash, it is removed for the purpose of the
  # following description, but it would only find a match with a directory. In
  # other words, foo/ will match a directory foo and paths underneath it, but
  # will not match a regular file or a symbolic link foo (this is consistent
  # with the way how pathspec works in general in Git).
  it "trailing slashes match directories and their contents but not regular files or symlinks" do
    spec = GitIgnoreSpec.new 'foo/'
    expect(spec.match('foo/')).to be_truthy
    expect(spec.match('foo/bar')).to be_truthy
    expect(spec.match('foo')).to be_nil
    expect(spec.inclusive?).to be true
  end

  # If the pattern does not contain a slash '/', Git treats it as a shell glob
  # pattern and checks for a match against the pathname relative to the location
  # of the .gitignore file (relative to the toplevel of the work tree if not
  # from a .gitignore file).
  it 'handles basic globbing' do
    spec = GitIgnoreSpec.new '*.tmp'
    expect(spec.match('foo.tmp')).to be_truthy
    expect(spec.match('foo.rb')).to be_nil
    expect(spec.inclusive?).to be true
  end

  it 'handles multiple globs' do
    spec = GitIgnoreSpec.new '*.middle.*'
    expect(spec.match('hello.middle.rb')).to be_truthy
    expect(spec.match('foo.rb')).to be_nil
    expect(spec.inclusive?).to be true
  end

  it 'handles dir globs' do
    spec = GitIgnoreSpec.new 'dir/*'
    expect(spec.match('dir/foo')).to be_truthy
    expect(spec.match('foo/')).to be_nil
    expect(spec.inclusive?).to be true
  end

  # Otherwise, Git treats the pattern as a shell glob suitable for consumption
  # by fnmatch(3) with the FNM_PATHNAME flag: wildcards in the pattern will not
  # match a / in the pathname. For example, "Documentation/*.html" matches
  # "Documentation/git.html" but not "Documentation/ppc/ppc.html" or
  # "tools/perf/Documentation/perf.html".
  it 'handles dir globs' do
    spec = GitIgnoreSpec.new 'dir/*'
    expect(spec.match('dir/foo')).to be_truthy
    expect(spec.match('foo/')).to be_nil
    expect(spec.inclusive?).to be true
  end

  it 'handles globs inside of dirs' do
    spec = GitIgnoreSpec.new 'Documentation/*.html'
    expect(spec.match('Documentation/git.html')).to be_truthy
    expect(spec.match('Documentation/ppc/ppc.html')).to be_nil
    expect(spec.match('tools/perf/Documentation/perf.html')).to be_nil
    expect(spec.inclusive?).to be true
  end

  # A leading slash matches the beginning of the pathname. For example, "/*.c"
  # matches "cat-file.c" but not "mozilla-sha1/sha1.c".
  it 'handles leading / as relative to base directory' do
    spec = GitIgnoreSpec.new '/*.c'
    expect(spec.match('cat-file.c')).to be_truthy
    expect(spec.match('mozilla-sha1/sha1.c')).to be_nil
    expect(spec.inclusive?).to be true
  end

  # Two consecutive asterisks ("**") in patterns matched against full pathname
  # may have special meaning:

  # A leading "**" followed by a slash means match in all directories. For
  # example, "**/foo" matches file or directory "foo" anywhere, the same as
  # pattern "foo". "**/foo/bar" matches file or directory "bar" anywhere that is
  # directly under directory "foo".
  it 'handles prefixed ** as searching any location' do
    spec = GitIgnoreSpec.new '**/foo'
    expect(spec.match('foo')).to be_truthy
    expect(spec.match('bar/foo')).to be_truthy
    expect(spec.match('baz/bar/foo')).to be_truthy
    expect(spec.match('baz/bar/foo.rb')).to be_nil
    expect(spec.inclusive?).to be true
  end

  it 'handles prefixed ** with a directory as searching a file under a directory in any location' do
    spec = GitIgnoreSpec.new '**/foo/bar'
    expect(spec.match('foo')).to be_nil
    expect(spec.match('foo/bar')).to be_truthy
    expect(spec.match('baz/foo/bar')).to be_truthy
    expect(spec.match('baz/foo/bar.rb')).to be_nil
    expect(spec.match('baz/bananafoo/bar')).to be_nil
    expect(spec.inclusive?).to be true
  end

  # A trailing "/**" matches everything inside. For example, "abc/**" matches
  # all files inside directory "abc", relative to the location of the .gitignore
  # file, with infinite depth.
  it 'handles leading /** as all files inside a directory' do
    spec = GitIgnoreSpec.new 'abc/**'
    expect(spec.match('abc/')).to be_truthy
    expect(spec.match('abc/def')).to be_truthy
    expect(spec.match('123/abc/def')).to be_nil
    expect(spec.match('123/456/abc')).to be_nil
    expect(spec.inclusive?).to be true
  end

  # A slash followed by two consecutive asterisks then a slash matches zero or
  # more directories. For example, "a/**/b" matches "a/b", "a/x/b", "a/x/y/b"
  # and so on.
  it 'handles /** in the middle of a path' do
    spec = GitIgnoreSpec.new 'a/**/b'
    expect(spec.match('a/b')).to be_truthy
    expect(spec.match('a/x/b')).to be_truthy
    expect(spec.match('a/x/y/b')).to be_truthy
    expect(spec.match('123/a/b')).to be_nil
    expect(spec.match('123/a/x/b')).to be_nil
    expect(spec.inclusive?).to be true
  end

  # Other consecutive asterisks are considered invalid.
  it 'considers other consecutive asterisks invalid' do
    spec = GitIgnoreSpec.new 'a/***/b'
    expect(spec.match('a/b')).to be_nil
    expect(spec.match('a/x/b')).to be_nil
    expect(spec.match('a/x/y/b')).to be_nil
    expect(spec.match('123/a/b')).to be_nil
    expect(spec.match('123/a/x/b')).to be_nil
    expect(spec.inclusive?).to be nil
  end
end
