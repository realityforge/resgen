require File.expand_path('../../helper', __FILE__)

# This test generates one test for each of the different input/generator combinations in the
# fixtures directory as documented in ../../fixtures/README
class TestFixtures < Resgen::TestCase

  Dir["#{fixture_dir}/*"].select { |base_fixture_name| File.directory?(base_fixture_name) }.each do |base_fixture_name|
    Dir["#{base_fixture_name}/output/*"].
      select { |generator_dir| File.directory?(generator_dir) }.
      collect { |generator_dir| File.basename(generator_dir) }.
      each do |generator_key|
      define_method("test_fixture_#{File.basename(base_fixture_name)}_with_generator_#{generator_key}") do
        run_test_for_fixture(base_fixture_name, generator_key)
      end
    end
  end

  def run_test_for_fixture(base_fixture_name, template_set_key, repository_name = :Planner)
    resource_filename = "#{base_fixture_name}/resources.rb"
    Resgen.current_filename = resource_filename
    load(resource_filename)
    Resgen.current_filename = nil

    repository = Resgen.repository_by_name(repository_name)
    output_directory = run_generators([template_set_key.to_sym], repository)

    expected_output_directory = "#{base_fixture_name}/output/#{template_set_key}"
    assert_no_diff(output_directory, expected_output_directory)
  end
end
