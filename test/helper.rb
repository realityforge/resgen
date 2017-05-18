$:.unshift File.expand_path('../../lib', __FILE__)

require File.expand_path("#{File.dirname(__FILE__)}/common_helper.rb")
require 'resgen'

module Resgen
  class << self
    def reset
      self.send(:repository_map).clear
    end
  end
end

class Resgen::TestCase < Minitest::Test
  include Test::Unit::Assertions

  def setup
    self.setup_working_dir
    Resgen.reset
  end

  def teardown
    self.teardown_working_dir
  end

  def run_generators(template_set_keys, repository, options = {})
    repository.send(:extension_point, :scan_if_required)
    repository.send(:extension_point, :validate)

    target_dir = options[:target_dir] || local_dir(::SecureRandom.hex)
    filter = options[:filter]
    Resgen::TemplateSetManager.generator.generate(:repository, repository, target_dir, template_set_keys, filter)
    target_dir
  end
end
