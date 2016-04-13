require 'bundler/setup'
Bundler.require :default, :development
require 'drb'
Test::Unit::AutoRunner.need_auto_run = false
require 'fluent/test'

Socket.instance_eval do
  def self.gethostname
    'localhost'
  end
end

require 'fluent/supervisor'

Dir["#{File.expand_path("../support", __FILE__)}/*.rb"].each {|f| require f}

require 'fluent/plugin/in_wire_protocol_compat'

RSpec.configure do |config|
  #config.fail_fast = true

  config.before :each do
    Fluent::Test.setup
  end

  config.after :each do
    stop_supervisor
    Timecop.return
  end

  config.order = "random"
end
