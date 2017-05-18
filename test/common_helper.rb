$:.unshift File.expand_path('../../lib', __FILE__)

require 'minitest/autorun'
require 'test/unit/assertions'
require 'securerandom'

module Resgen
  module TestUtil
    # The base test directory
    def self.base_test_dir
      File.expand_path("#{File.dirname(__FILE__)}")
    end

    # The fixtures directory
    def self.fixture_dir
      "#{base_test_dir}/fixtures"
    end
  end
  module TestCaseHelpers
    def setup_working_dir
      @cwd = Dir.pwd

      FileUtils.mkdir_p self.working_dir
      Dir.chdir(self.working_dir)
    end

    def teardown_working_dir
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

    def fixture(fixture_name)
      "#{TestUtil.fixture_dir}/#{fixture_name}"
    end

    def assert_fixture_matches_output(fixture_name, output_filename)
      assert_equal true, File.exist?(output_filename), "Expected filename to be created #{output_filename}"
      assert_equal IO.read(fixture(fixture_name)), IO.read(output_filename), "Content generated into #{output_filename}"
    end

    def in_dir(dir)
      Dir.chdir(dir)
      yield
    end

    def assert_no_diff(path1, path2)
      run_command("diff -r -U 3 #{path1} #{path2}")
    end

    def run_command(command)
      output = `#{command}`
      raise "Error executing command: #{command}\nOutput: #{output}" unless $?.success?
      output
    end

    def assert_output_directories_matches(expected_output_directory, output_directory, template_set_keys)
      if File.exist?(output_directory)
        assert_no_diff(output_directory, expected_output_directory)
      else
        files = (Dir["#{expected_output_directory}/.*"] + Dir["#{expected_output_directory}/*"])
        files = files.select { |f| File.basename(f) != '.' && File.basename(f) != '..' }

        # The fixtures signal that it was not expected that a directory was created
        # by having a directory whos only contents is .keep
        unless files.size == 1 && File.basename(files[0]) == '.keep'
          fail "Generator(s) #{template_set_keys.inspect} failed to generate expected directory that matches #{expected_output_directory}"
        end
      end
    end
  end
end
