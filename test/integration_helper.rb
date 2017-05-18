$:.unshift File.expand_path('../../lib', __FILE__)

require File.expand_path("#{File.dirname(__FILE__)}/common_helper.rb")

class Resgen::IntegrationTestCase < Minitest::Test
  include Test::Unit::Assertions
  include Resgen::TestCaseHelpers

  def setup
    self.setup_working_dir
  end

  def teardown
    self.teardown_working_dir
  end

  def run_resgen(args)
    prefix = (defined?(JRUBY_VERSION) || Gem.win_platform?) ? 'ruby ' : ''
    command = File.expand_path("#{File.dirname(__FILE__)}/../bin/resgen")
    run_command("#{prefix}#{command} #{args}")
  end
end
