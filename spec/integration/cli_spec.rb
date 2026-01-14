# frozen_string_literal: true

require 'spec_helper'
require 'open3'
require 'tmpdir'

describe 'pathspec-rb CLI' do
  let(:cli_path) { File.expand_path('../../bin/pathspec-rb', __dir__) }
  let(:lib_path) { File.expand_path('../../lib', __dir__) }
  let(:gitignore_simple) { File.expand_path('../files/gitignore_simple', __dir__) }
  let(:gitignore_readme) { File.expand_path('../files/gitignore_readme', __dir__) }
  let(:regex_simple) { File.expand_path('../files/regex_simple', __dir__) }

  def run_cli(*args)
    env = { 'RUBYLIB' => lib_path }
    stdout, stderr, status = Open3.capture3(env, 'ruby', cli_path, *args)
    [stdout, stderr, status]
  end

  describe 'help and errors' do
    it 'shows help when no arguments provided' do
      stdout, _stderr, status = run_cli
      expect(stdout).to include('Usage: pathspec-rb')
      expect(stdout).to include('Subcommands:')
      expect(stdout).to include('specs_match')
      expect(stdout).to include('tree')
      expect(stdout).to include('match')
      expect(status.exitstatus).to eq(2)
    end

    it 'shows error for unreadable file' do
      stdout, _stderr, status = run_cli('-f', '/nonexistent/file', 'match', 'test.txt')
      expect(stdout).to include("Error: I couldn't read /nonexistent/file")
      expect(status.exitstatus).to eq(2)
    end

    it 'shows error for unknown subcommand' do
      stdout, _stderr, status = run_cli('-f', gitignore_simple, 'unknown_command', 'test.txt')
      expect(stdout).to include('Unknown sub-command unknown_command')
      expect(stdout).to include('Usage: pathspec-rb')
      expect(status.exitstatus).to eq(2)
    end
  end

  describe 'match subcommand' do
    context 'with matching path' do
      it 'exits with 0' do
        _stdout, _stderr, status = run_cli('-f', gitignore_simple, 'match', 'test.md')
        expect(status.exitstatus).to eq(0)
      end

      it 'shows match message with verbose flag' do
        stdout, _stderr, status = run_cli('-f', gitignore_simple, '-v', 'match', 'test.md')
        expect(stdout).to include('test.md matches a spec')
        expect(status.exitstatus).to eq(0)
      end
    end

    context 'with non-matching path' do
      it 'exits with 1' do
        _stdout, _stderr, status = run_cli('-f', gitignore_simple, 'match', 'other.txt')
        expect(status.exitstatus).to eq(1)
      end

      it 'shows no match message with verbose flag' do
        stdout, _stderr, status = run_cli('-f', gitignore_simple, '-v', 'match', 'other.txt')
        expect(stdout).to include('other.txt does not match')
        expect(status.exitstatus).to eq(1)
      end
    end

    context 'with negated pattern' do
      it 'does not match negated paths' do
        _stdout, _stderr, status = run_cli('-f', gitignore_readme, 'match', 'abc/important.txt')
        expect(status.exitstatus).to eq(1)
      end

      it 'matches non-negated paths' do
        _stdout, _stderr, status = run_cli('-f', gitignore_readme, 'match', 'abc/other.txt')
        expect(status.exitstatus).to eq(0)
      end
    end
  end

  describe 'specs_match subcommand' do
    context 'with matching path' do
      it 'exits with 0 and shows matching specs' do
        stdout, _stderr, status = run_cli('-f', gitignore_readme, 'specs_match', 'abc/def.rb')
        expect(stdout).to include('abc/**')
        expect(status.exitstatus).to eq(0)
      end

      it 'shows verbose message with -v flag' do
        stdout, _stderr, status = run_cli('-f', gitignore_readme, '-v', 'specs_match', 'abc/def.rb')
        expect(stdout).to include('abc/def.rb matches the following specs')
        expect(stdout).to include('abc/**')
        expect(status.exitstatus).to eq(0)
      end
    end

    context 'with non-matching path' do
      it 'exits with 1' do
        _stdout, _stderr, status = run_cli('-f', gitignore_readme, 'specs_match', 'xyz/file.txt')
        expect(status.exitstatus).to eq(1)
      end

      it 'shows no match message with verbose flag' do
        stdout, _stderr, status = run_cli('-f', gitignore_readme, '-v', 'specs_match', 'xyz/file.txt')
        expect(stdout).to include('xyz/file.txt does not match any specs')
        expect(status.exitstatus).to eq(1)
      end
    end
  end

  describe 'tree subcommand' do
    around do |example|
      Dir.mktmpdir do |temp_dir|
        @temp_dir = temp_dir
        example.run
      end
    end

    before do
      # Create test directory structure
      FileUtils.mkdir_p(File.join(@temp_dir, 'foo'))
      FileUtils.mkdir_p(File.join(@temp_dir, 'other'))
      FileUtils.touch(File.join(@temp_dir, 'foo', 'test.txt'))
      FileUtils.touch(File.join(@temp_dir, 'foo', 'another.txt'))
      FileUtils.touch(File.join(@temp_dir, 'other', 'file.txt'))

      # Create a gitignore that matches foo/**
      @temp_gitignore = File.join(@temp_dir, '.gitignore')
      File.write(@temp_gitignore, "foo/**\n")
    end

    context 'with matching files' do
      it 'exits with 0 and lists matching files' do
        stdout, _stderr, status = run_cli('-f', @temp_gitignore, 'tree', @temp_dir)
        expect(stdout).to include('foo')
        expect(stdout.lines.any? { |line| line.include?('other') && !line.include?('another') }).to be false
        expect(status.exitstatus).to eq(0)
      end

      it 'shows verbose message with -v flag' do
        stdout, _stderr, status = run_cli('-f', @temp_gitignore, '-v', 'tree', @temp_dir)
        expect(stdout).to include("Files in #{@temp_dir} that match")
        expect(status.exitstatus).to eq(0)
      end
    end

    context 'with no matching files' do
      before do
        # Create gitignore with pattern that won't match anything
        File.write(@temp_gitignore, "nomatch/**\n")
      end

      it 'exits with 1' do
        _stdout, _stderr, status = run_cli('-f', @temp_gitignore, 'tree', @temp_dir)
        expect(status.exitstatus).to eq(1)
      end

      it 'shows no match message with verbose flag' do
        stdout, _stderr, status = run_cli('-f', @temp_gitignore, '-v', 'tree', @temp_dir)
        expect(stdout).to include('No file')
        expect(stdout).to include('matched')
        expect(status.exitstatus).to eq(1)
      end
    end
  end

  describe 'type flag' do
    context 'with git type (default)' do
      it 'parses gitignore patterns' do
        _stdout, _stderr, status = run_cli('-f', gitignore_simple, '-t', 'git', 'match', 'test.md')
        expect(status.exitstatus).to eq(0)
      end
    end

    context 'with regex type' do
      it 'parses regex patterns' do
        _stdout, _stderr, status = run_cli('-f', regex_simple, '-t', 'regex', 'match', 'foo.md')
        expect(status.exitstatus).to eq(0)
      end
    end
  end

  describe 'file flag' do
    it 'uses default .gitignore when not specified' do
      Dir.mktmpdir do |dir|
        gitignore_path = File.join(dir, '.gitignore')
        File.write(gitignore_path, "test/**\n")

        Dir.chdir(dir) do
          _stdout, _stderr, status = run_cli('match', 'test/file.txt')
          expect(status.exitstatus).to eq(0)
        end
      end
    end

    it 'uses specified file with -f flag' do
      _stdout, _stderr, status = run_cli('-f', gitignore_simple, 'match', 'test.md')
      expect(status.exitstatus).to eq(0)
    end

    it 'uses specified file with --file flag' do
      _stdout, _stderr, status = run_cli('--file', gitignore_simple, 'match', 'test.md')
      expect(status.exitstatus).to eq(0)
    end
  end

  describe 'empty string match command' do
    it 'treats empty string as match command' do
      _stdout, _stderr, status = run_cli('-f', gitignore_simple, '', 'test.md')
      expect(status.exitstatus).to eq(0)
    end
  end
end
