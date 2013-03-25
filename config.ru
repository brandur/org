require "bundler/setup"
Bundler.require

# so logging output appears properly
$stdout.sync = true

Slim::Engine.set_default_options format: :html5, pretty: true

#DB = Sequel.connect(ENV["DATABASE_URL"] ||
#  raise("missing_environment=DATABASE_URL"))

require "./lib/brandur_org"

run BrandurOrg::Main
