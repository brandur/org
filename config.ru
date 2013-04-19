require "bundler/setup"
Bundler.require

# so logging output appears properly
$stdout.sync = true

# configuration
Slim::Engine.set_default_options format: :html5, pretty: true
Slim::Embedded.default_options[:markdown] = { fenced_code_blocks: true }

require "./lib/brandur_org"

run BrandurOrg::Main
