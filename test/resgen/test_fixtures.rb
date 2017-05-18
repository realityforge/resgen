require File.expand_path('../../helper', __FILE__)

# This test generates one test for each of the different input/generator combinations in the
# fixtures directory as documented in ../../fixtures/README
class TestFixtures < Resgen::TestCase

  Dir["#{fixture_dir}/*"].select { |base_fixture_name| File.directory?(base_fixture_name) }.each do |base_fixture_name|
    generator_keys = Dir["#{base_fixture_name}/output/*"].
      select { |generator_dir| File.directory?(generator_dir) }.
      collect { |generator_dir| File.basename(generator_dir) }
    generator_keys.each do |generator_key|
      define_method("test_fixture_#{File.basename(base_fixture_name)}_with_generator_#{generator_key}") do
        run_test_for_fixture(base_fixture_name, generator_key)
      end
    end
    define_method("test_fixture_#{File.basename(base_fixture_name)}_with_generators_#{generator_keys.join('_and_')}") do
      run_test_for_fixtures(base_fixture_name, generator_keys)
    end
  end

  def run_test_for_fixtures(base_fixture_name, template_set_keys, repository_name = :Planner)
    repository = load_repository(base_fixture_name, repository_name)
    output_directory = run_generators(template_set_keys.collect{|k| k.to_sym}, repository)

    expected_output_directory = local_dir(::SecureRandom.hex)

    FileUtils.mkdir_p(expected_output_directory)
    template_set_keys.each do |template_set_key|
      FileUtils.cp_r("#{base_fixture_name}/output/#{template_set_key}/.", expected_output_directory)
    end
    FileUtils.rm_f("#{expected_output_directory}/.keep")

    assert_output_directories_matches(expected_output_directory, output_directory, template_set_keys)
  end

  def run_test_for_fixture(base_fixture_name, template_set_key, repository_name = :Planner)
    repository = load_repository(base_fixture_name, repository_name)

    output_directory = run_generators([template_set_key.to_sym], repository)

    expected_output_directory = "#{base_fixture_name}/output/#{template_set_key}"

    assert_output_directories_matches(expected_output_directory, output_directory, [template_set_key])
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

  def load_repository(base_fixture_name, repository_name)
    resource_filename = "#{base_fixture_name}/resources.rb"
    Resgen.current_filename = resource_filename
    load(resource_filename)
    Resgen.current_filename = nil

    Resgen.repository_by_name(repository_name)
  end
end
