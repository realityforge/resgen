$:.unshift File.expand_path('../../lib', __FILE__)

require 'minitest/autorun'
require 'test/unit/assertions'
require 'securerandom'
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
    @cwd = Dir.pwd

    FileUtils.mkdir_p self.working_dir
    Dir.chdir(self.working_dir)

    Resgen.reset
  end

  def teardown
    Dir.chdir(@cwd)
    if passed?
      FileUtils.rm_rf self.working_dir if File.exist?(self.working_dir)
    else
      $stderr.puts "Test #{self.class.name}.#{name} Failed. Leaving working directory #{self.working_dir}"
    end
  end

  def local_dir(directory)
    "#{working_dir}/#{directory}"
  end

  def working_dir
    @working_dir ||= "#{workspace_dir}/#{::SecureRandom.hex}"
  end

  def workspace_dir
    @workspace_dir ||= ENV['TEST_TMP_DIR'] || File.expand_path("#{File.dirname(__FILE__)}/../tmp/workspace")
  end

  # The base test directory
  def base_test_dir
    @base_test_dir ||= File.expand_path("#{File.dirname(__FILE__)}")
  end

  # The fixtures directory
  def fixture_dir
    "#{base_test_dir}/fixtures"
  end

  def fixture(fixture_name)
    "#{fixture_dir}/#{fixture_name}"
  end

  def assert_fixture_matches_output(fixture_name, output_filename)
    assert_equal true, File.exist?(output_filename), "Expected filename to be created #{output_filename}"
    assert_equal IO.read(fixture(fixture_name)), IO.read(output_filename), "Content generated into #{output_filename}"
  end

  def run_generators(template_set_keys, repository, options = {})
    target_dir = options[:target_dir] || local_dir(::SecureRandom.hex)
    filter = options[:filter]
    Resgen::TemplateSetManager.generator.generate(:repository, repository, target_dir, template_set_keys, filter)
    target_dir
  end

  def in_dir(dir)
    Dir.chdir(dir)
    yield
  end

  def assert_no_diff(path1, path2)
    run_command("diff -U 3 #{path1} #{path2}")
  end

  def run_command(command)
    output = `#{command}`
    raise "Error executing command: #{command}\nOutput: #{output}" unless $?.success?
    output
  end
end
