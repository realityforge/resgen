#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'optparse'

require 'resgen'

default_generators = []

descriptors = []
generators = default_generators
repository_name = nil
verbose = false
target_dir = File.expand_path('generated')

opt_parser = OptionParser.new do |opt|
  opt.banner = 'Usage: resgen [OPTIONS]'
  opt.separator ''
  opt.separator 'Options'

  opt.on('-d', '--descriptor FILENAME', "the filename of a descriptor to be loaded. Many descriptors may be loaded. Defaults to 'resources.rb' if none specified.") do |arg|
    descriptors << arg
  end

  opt.on('-r', '--repository NAME', 'the name of repository to load. Defaults to the loaded repository name if only one repository loaded otherwise must be specified.') do |arg|
    repository_name = arg
  end

  opt.on('-g', '--generator GENERATORS', "the comma separated list of generators to run. Defaults to #{default_generators.inspect}") do |arg|
    generators += arg.split(',').collect{|g|g.to_sym}
  end

  opt.on('-t', '--target-dir DIR', "the directory into which to generate artifacts. Defaults to 'generated'.") do |arg|
    target_dir = arg
  end

  opt.on('-v', '--verbose', 'turn on verbose logging.') do
    verbose = true
  end

  opt.on('-h', '--help', 'help') do
    puts opt_parser
    exit(53)
  end
end

begin
  opt_parser.parse!
rescue => e
  puts "Error: #{e.message}"
  exit(53)
end

if ARGV.length != 0
  puts 'Unexpected argument passed to command'
  puts opt_parser
  exit(31)
end

DEFAULT_DESCRIPTOR = 'resources.rb'

if verbose
  puts "Repository Name: #{repository_name || 'Unspecified'}"
  puts "Target Dir: #{target_dir}"
  if descriptors.size == 0
    puts "Descriptor: #{DEFAULT_DESCRIPTOR} (Default)"
  elsif descriptors.size < 2
    puts "Descriptor: #{descriptors[0]}"
  else
    puts 'Descriptors:'
    descriptors.each do |descriptor|
      puts "\t * #{descriptor}"
    end
  end
  puts 'Generators:'
  generators.each do |generator|
    puts "\t * #{generator}"
  end
end

descriptors << DEFAULT_DESCRIPTOR if 0 == descriptors.size

Resgen::Logger.level = ::Logger::INFO if verbose

descriptors.each do |descriptor|
  puts "Loading descriptor: #{descriptor}" if verbose
  filename = File.expand_path(descriptor)
  unless File.exist?(filename)
    puts "Descriptor file #{filename} does not exist"
    exit(43)
  end
  Resgen.current_filename = filename
  require filename
  Resgen.current_filename = nil
  puts "Descriptor loaded: #{descriptor}" if verbose
end

unless repository_name
  repository_names = Resgen.repositories.collect { |r| r.name }
  if repository_names.size == 1
    repository_name = repository_names[0]
    puts "Derived default repository name: #{repository_name}" if verbose
  else
    puts "No repository name specified and repository name could not be determined. Please specify one of the valid repository names: #{repository_names.join(', ')}"
    exit(36 )
  end
end

unless Resgen.repository_by_name?(repository_name)
  puts "Specified repository name '#{repository_name}' does not exist in descriptors."
  exit(36)
end

repository = Resgen.repository_by_name(repository_name)
repository.send(:extension_point, :scan_if_required)
repository.send(:extension_point, :validate)

Resgen::TemplateSetManager.generator.generate(:repository,
                                              repository,
                                              File.expand_path(target_dir),
                                              generators,
                                              nil)
