===========
pathspec-rb
===========

--------------------------------------
Test pathspecs against a specific path
--------------------------------------

:Author: Gabriel Filion
:Date: 2019
:Manual section: 1

Synopsis
========

| pathspec-rb [options] [subcommand] [path] <name> <path>

Description
===========

``pathspc-rb`` is a tool that accompanies the pathspec-ruby library to help
you test what match results the library would find using path specs. You can
either find all specs matching a path, find all files matching specs, or
verify that a path would match any spec.

Sub-commands
============

| **specs_match** Find all specs matching path
| **tree**        Find all files under path matching the spec
| **match**       Check if the path matches any spec

Options
=======

| **-f** | **--file** <FILENAME>
|     Load path specs from the file passed in as argument. If this option is
|     not specified, ``pathspec-rb`` defaults to loading ``.gitignore``.

| **-t** | **--type** [``git``\ \|\ ``regex``]
|     Type of spec expected in the loaded specs file (see **-f** option).
|     Defaults to ``git``.

| **-v** | **--verbose**
|     Only output if there are matches.

Examples
========

Find all files ignored by git under your source directory::

      $ pathspec-rb tree src/

List all spec rules that would match for the specified path::

      $ pathspec-rb specs_match build/

Check that a path matches at least one of the specs in a new version of a
gitignore file::

      $ pathspec-rb match -f .gitignore.new spec/fixtures/

