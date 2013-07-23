require "bundler/setup"
Bundler.require

# so logging output appears properly
$stdout.sync = true

# configuration
Slim::Engine.set_default_options format: :html5, pretty: true
Slim::Embedded.default_options[:markdown] = {
  autolink:           true,
  fenced_code_blocks: true,
  strikethrough:      true,
  superscript:        true,
  tables:             true,
}

require "./lib/org"

run Org::Main
