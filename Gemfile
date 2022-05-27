Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

source "https://rubygems.org"

# Specify your gem's dependencies in gemspec
gemspec

if File.exist? "Gemfile.devel"
  eval File.read("Gemfile.devel"), nil, "Gemfile.devel" # rubocop:disable Security/Eval
end
