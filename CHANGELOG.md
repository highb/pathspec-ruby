# pathspec-ruby CHANGELOG

## 0.2.0 (Minor Release)
- New namespace for gem: `PathSpec`: Everything is now namespaced under `PathSpec`, to prevent naming collisions with other libraries.

## 0.1.2 (Patch/Bug Fix Release)
- Fix for regexp matching Thanks @incase! #16
- File handling cleanup Thanks @martinandert! #13
- `from_filename` actually works now! Thanks @martinandert! #12

## 0.1.0 (Minor Release)
- Port new edgecase handling from [python-path-specification](https://github.com/cpburnz/python-path-specification/pull/8). Many thanks to @jdpace! :)
- Removed EOL Ruby support
- Added current Ruby stable to Travis testing

## 0.0.2 (Patch/Bug Fix Release)
- Fixed issues with Ruby 1.8.7/2.1.1
- Added more testing scripts
- Fixed Windows path related issues
- Cleanup unnecessary things in gem

## 0.0.1
- Initial version.
