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
default_descriptor = 'resources.rb'
tool_name = 'resgen'
element_type_name = 'repository'
element_type_name_char_code = nil
default_target_dir = nil

descriptors = []
default_target_dir ||= 'generated'
generators = default_generators
element_name = nil
verbose = false
debug = false
target_dir = File.expand_path(default_target_dir)
element_type_name_char_code |= element_type_name[0, 1]

opt_parser = OptionParser.new do |opt|
  opt.banner = "Usage: #{tool_name} [OPTIONS]"
  opt.separator ''
  opt.separator 'Options'

  opt.on('-d', '--descriptor FILENAME', "the filename of a descriptor to be loaded. Many descriptors may be loaded. Defaults to 'resources.rb' if none specified.") do |arg|
    descriptors << arg
  end

  opt.on("-#{element_type_name_char_code}",
         "--#{element_type_name} NAME",
         "the name of the #{element_type_name} to load. Defaults to the the name of the only #{element_type_name} if there is only one #{element_type_name} defined by the descriptors, otherwise must be specified.") do |arg|
    element_name = arg
  end

  opt.on('-g', '--generator GENERATORS', "the comma separated list of generators to run. Defaults to #{default_generators.inspect}") do |arg|
    generators += arg.split(',').collect{|g|g.to_sym}
  end

  opt.on('-t', '--target-dir DIR', "the directory into which to generate artifacts. Defaults to '#{default_target_dir}'.") do |arg|
    target_dir = arg
  end

  opt.on('-v', '--verbose', 'turn on verbose logging.') do
    verbose = true
  end

  opt.on('--debug', 'turn on debug logging.') do
    debug = true
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

if 0 == descriptors.size
  puts "No descriptor specified. Defaulting to #{default_descriptor}" if verbose
  descriptors << default_descriptor
end

Reality::Logging.set_levels(debug ? ::Logger::DEBUG : verbose ? ::Logger::INFO : ::Logger::WARN,
                            Resgen::Logger,
                            Reality::Generators::Logger,
                            Reality::Facets::Logger)

if verbose
  puts "#{Reality::Naming.humanize(element_type_name)} Name: #{element_name || 'Unspecified'}"
  puts "Target Dir: #{target_dir}"
  if descriptors.size == 1
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

unless element_name
  element_names = Resgen.repositories.collect { |r| r.name }
  if element_names.size == 1
    element_name = element_names[0]
    puts "Derived default #{Reality::Naming.humanize(element_type_name)} name: #{element_name}" if verbose
  else
    puts "No #{Reality::Naming.humanize(element_type_name).downcase} name specified and #{Reality::Naming.humanize(element_type_name).downcase} name could not be determined. Please specify one of the valid #{Reality::Naming.humanize(element_type_name).downcase} names: #{element_names.join(', ')}"
    exit(36 )
  end
end

unless Resgen.repository_by_name?(element_name)
  puts "Specified #{Reality::Naming.humanize(element_type_name).downcase} name '#{element_name}' does not exist in descriptors."
  exit(36)
end

repository = Resgen.repository_by_name(element_name)
repository.send(:extension_point, :scan_if_required)
repository.send(:extension_point, :validate)

Resgen::TemplateSetManager.generator.generate(:repository,
                                              repository,
                                              File.expand_path(target_dir),
                                              generators,
                                              nil)
