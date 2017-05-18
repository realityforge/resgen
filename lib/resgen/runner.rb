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

class Runner

  def initialize
    @descriptors = []
    @generators = self.default_generators
    @target_dir = nil
    @element_name = nil
    @verbose = false
    @debug = false
  end

  def default_generators
    []
  end

  def default_descriptor
    'resources.rb'
  end

  def tool_name
    'resgen'
  end

  def element_type_name
    'repository'
  end

  def element_type_name_char_code
    self.element_type_name[0, 1]
  end

  def default_target_dir
    'generated'
  end

  attr_writer :verbose

  def verbose?
    !!@verbose
  end

  attr_writer :debug

  def debug?
    !!@debug
  end

  attr_writer :target_dir

  def target_dir
    @target_dir || self.default_target_dir
  end

  attr_accessor :generators

  attr_accessor :descriptors

  attr_accessor :element_name

  def run
    opt_parser = OptionParser.new do |opt|
      opt.banner = "Usage: #{tool_name} [OPTIONS]"
      opt.separator ''
      opt.separator 'Options'

      opt.on('-d', '--descriptor FILENAME', "the filename of a descriptor to be loaded. Many descriptors may be loaded. Defaults to 'resources.rb' if none specified.") do |arg|
        self.descriptors << arg
      end

      opt.on("-#{self.element_type_name_char_code}",
             "--#{self.element_type_name} NAME",
             "the name of the #{self.element_type_name} to load. Defaults to the the name of the only #{element_type_name} if there is only one #{self.element_type_name} defined by the descriptors, otherwise must be specified.") do |arg|
        self.element_name = arg
      end

      opt.on('-g', '--generator GENERATORS', "the comma separated list of generators to run. Defaults to #{default_generators.inspect}") do |arg|
        self.generators += arg.split(',').collect { |g| g.to_sym }
      end

      opt.on('-t', '--target-dir DIR', "the directory into which to generate artifacts. Defaults to '#{self.default_target_dir}'.") do |arg|
        self.target_dir = arg
      end

      opt.on('-v', '--verbose', 'turn on verbose logging.') do
        self.verbose = true
      end

      opt.on('--debug', 'turn on debug logging.') do
        self.verbose = true
        self.debug = true
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

    if 0 == self.descriptors.size
      puts "No descriptor specified. Defaulting to #{default_descriptor}" if verbose?
      self.descriptors << default_descriptor
    end

    Reality::Logging.set_levels(debug? ? ::Logger::DEBUG : verbose? ? ::Logger::INFO : ::Logger::WARN,
                                Resgen::Logger,
                                Reality::Generators::Logger,
                                Reality::Facets::Logger)

    if verbose?
      puts "#{Reality::Naming.humanize(self.element_type_name)} Name: #{self.element_name || 'Unspecified'}"
      puts "Target Dir: #{self.target_dir}"
      if self.descriptors.size == 1
        puts "Descriptor: #{self.descriptors[0]}"
      else
        puts 'Descriptors:'
        self.descriptors.each do |descriptor|
          puts "\t * #{descriptor}"
        end
      end
      puts 'Generators:'
      self.generators.each do |generator|
        puts "\t * #{generator}"
      end
    end

    self.descriptors.each do |descriptor|
      puts "Loading descriptor: #{descriptor}" if verbose?
      filename = File.expand_path(descriptor)
      unless File.exist?(filename)
        puts "Descriptor file #{filename} does not exist"
        exit(43)
      end
      Resgen.current_filename = filename
      require filename
      Resgen.current_filename = nil
      puts "Descriptor loaded: #{descriptor}" if verbose?
    end

    unless self.element_name
      element_names = Resgen.repositories.collect { |r| r.name }
      if element_names.size == 1
        self.element_name = element_names[0]
        puts "Derived default #{Reality::Naming.humanize(self.element_type_name)} name: #{self.element_name}" if verbose?
      else
        puts "No #{Reality::Naming.humanize(self.element_type_name).downcase} name specified and #{Reality::Naming.humanize(element_type_name).downcase} name could not be determined. Please specify one of the valid #{Reality::Naming.humanize(self.element_type_name).downcase} names: #{element_names.join(', ')}"
        exit(36)
      end
    end

    unless Resgen.repository_by_name?(self.element_name)
      puts "Specified #{Reality::Naming.humanize(self.element_type_name).downcase} name '#{self.element_name}' does not exist in descriptors."
      exit(36)
    end

    element = Resgen.repository_by_name(self.element_name)

    Resgen::TemplateSetManager.generator.generate(element_type_name.to_sym,
                                                  element,
                                                  File.expand_path(self.target_dir),
                                                  self.generators,
                                                  nil)

    exit 0
  end
end

Runner.new.run
