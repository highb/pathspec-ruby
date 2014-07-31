require_relative '../spec_helper'
require 'fakefs/safe'
require 'pathspec'
require 'fakefs/spec_helpers'

describe PathSpec do
  shared_examples "standard gitignore negation" do
    it { is_expected.to_not match('important.txt') }
    it { is_expected.to_not match('foo/important.txt') }
    it { is_expected.to match('foo/bar/') }
  end

  context "initialization" do
    context "from multilines" do
      context "#new" do
        subject { PathSpec.new <<-IGNORELINES
!important.txt
foo/**
/bar/baz
IGNORELINES
        }

        it_behaves_like "standard gitignore negation"
      end
    end

    context "from array of gitignore strings" do
      let(:arr) { ["!important.txt", "foo/**", "/bar/baz"] }

      context "#new" do
        subject { PathSpec.new arr }

        it_behaves_like "standard gitignore negation"
      end

      context "#from_lines" do
        subject {
          PathSpec.from_lines(arr)
        }

        it_behaves_like "standard gitignore negation"
      end

      context "#add array" do
        subject {
          ps = PathSpec.new []
          ps.add arr
        }

        it_behaves_like "standard gitignore negation"
      end
    end

    context "from linedelimited gitignore string" do
      let(:line) { "!important.txt\nfoo/**\n/bar/baz\n" }

      context "#new" do
        subject { PathSpec.new line }

        it_behaves_like "standard gitignore negation"
      end

      context "#from_lines" do
        subject {
          PathSpec.from_lines(line)
        }

        it_behaves_like "standard gitignore negation"
      end

      context "#add" do
        subject {
          ps = PathSpec.new
          ps.add line
        }

        it_behaves_like "standard gitignore negation"
      end
    end

    context "from a gitignore file" do
      include FakeFS::SpecHelpers

      let(:filename) { '.gitignore' }
      before(:each) do
        file = File.open(filename, 'w') { |f|
          f << "!important.txt\n"
          f << "foo/**\n"
          f << "/bar/baz\n"
        }
      end

      context "#new" do
        subject {
          PathSpec.new File.open(filename, 'r')
        }

        it_behaves_like "standard gitignore negation"
      end

      context "#from_filename" do
        subject {
          PathSpec.from_filename(filename)
        }

        it_behaves_like "standard gitignore negation"
      end
    end

    context "from multiple gitignore files" do
      include FakeFS::SpecHelpers

      let(:filenames) { ['.gitignore', '.otherignore'] }
      before(:each) do
        file = File.open('.gitignore', 'w') { |f|
          f << "!important.txt\n"
          f << "foo/**\n"
          f << "/bar/baz\n"
        }

        file = File.open('.otherignore', 'w') { |f|
          f << "ban*na\n"
          f << "!banana\n"
        }
      end

      context "#new" do
        subject {
          arr = filenames.collect { |f| File.open(f, 'r') }
          PathSpec.new arr
        }

        it_behaves_like "standard gitignore negation"

        it { is_expected.to_not match('banana') }
        it { is_expected.to match('banananananana') }
      end

      context "#add" do
        subject {
          arr = filenames.collect { |f| File.open(f, 'r') }
          ps = PathSpec.new
          ps.add arr
        }

        it_behaves_like "standard gitignore negation"

        it { is_expected.to_not match('banana') }
        it { is_expected.to match('banananananana') }
      end
    end
  end

  context "#match_tree" do
    let(:root) {'/tmp/project'}
    let(:gitignore) { <<-GITIGNORE
!**/important.txt
abc/**
GITIGNORE
    }

    before(:each) {
      FileUtils.mkdir_p root
      FileUtils.mkdir_p "#{root}/abc"
      FileUtils.touch "#{root}/abc/1"
      FileUtils.touch "#{root}/abc/2"
      FileUtils.touch "#{root}/abc/important.txt"
    }

    subject {
      PathSpec.new(gitignore).match_tree(root)
    }

    it { is_expected.to include Pathname.new "#{root}/abc" }
    it { is_expected.to include Pathname.new "#{root}/abc/1" }
    it { is_expected.not_to include Pathname.new "#{root}/abc/important.txt" }
    it { is_expected.not_to include Pathname.new "#{root}" }
  end

  context "#match_paths" do
    let(:gitignore) { <<-GITIGNORE
!**/important.txt
/abc/**
GITIGNORE
    }

    context "with no root arg" do
      subject { PathSpec.new(gitignore).match_paths(['/abc/important.txt', '/abc/', '/abc/1']) }

      it { is_expected.to include Pathname.new "/abc/" }
      it { is_expected.to include Pathname.new "/abc/1" }
      it { is_expected.not_to include Pathname.new "/abc/important.txt" }
    end

    it 'matches the paths relative to non-root' do
      matched = subject.match_paths(['/def/abc/important.txt', '/def/abc/', '/def/abc/1'], '/def')
      expect(matched).to include Pathname.new "/def/abc/"
      expect(matched).to include Pathname.new "/def/abc/1"
      expect(matched).not_to include Pathname.new "/def/abc/important.txt"
    end
  end

  context "#empty" do
    let(:gitignore) { <<-GITIGNORE
# A comment
GITIGNORE
    }

    subject { PathSpec.new gitignore }

    it 'is empty when there are no valid lines' do
      expect(subject.empty?).to be true
    end
  end

  context "regex file" do
    let(:regexfile) { <<-REGEX
/ab+a/
REGEX
    }

    subject { PathSpec.new regexfile, :regex}

    it "matches the regex" do
      expect(subject.match('anna')).to be false
      expect(subject.match('abba')).to be true
    end
  end
end
