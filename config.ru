require "bundler/setup"
Bundler.require

# so logging output appears properly
$stdout.sync = true

require "./lib/org"

# configuration
DB = Sequel.connect(Org::Config.black_swan_database_url)
Slim::Engine.set_default_options format: :html5, pretty: true
Slim::Embedded.default_options[:markdown] = {
  autolink:           false,
  fenced_code_blocks: true,
  strikethrough:      true,
  superscript:        true,
  tables:             true,
}

run Org::Main
