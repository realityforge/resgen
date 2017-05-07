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

module Resgen #nodoc
  class Build #nodoc
    DEFAULT_RESOURCES_FILENAME = 'resources.rb'

    def self.define_load_task(filename = nil, &block)
      base_directory = File.dirname(Buildr.application.buildfile.to_s)
      candidate_file = File.expand_path("#{base_directory}/#{DEFAULT_RESOURCES_FILENAME}")
      if filename.nil?
        filename = candidate_file
      elsif File.expand_path(filename) == candidate_file
        Resgen.warn("Resgen::Build.define_load_task() passed parameter '#{filename}' which is the same value as the default parameter. This parameter can be removed.")
      end
      Resgen::LoadResourceDescriptor.new(File.expand_path(filename), &block)
    end

    def self.define_generate_task(generator_keys, options = {}, &block)
      repository_key = options[:repository_key]
      target_dir = options[:target_dir]
      buildr_project = options[:buildr_project]

      if buildr_project.nil? && Buildr.application.current_scope.size > 0
        buildr_project = Buildr.project(Buildr.application.current_scope.join(':')) rescue nil
      end

      build_key = options[:key] || (buildr_project.nil? ? :default : buildr_project.name.split(':').last)

      if target_dir
        base_directory = File.dirname(Buildr.application.buildfile.to_s)
        target_dir = File.expand_path(target_dir, base_directory)
      end

      if target_dir.nil? && !buildr_project.nil?
        target_dir = buildr_project._(:target, :generated, 'resgen', build_key)
      elsif !target_dir.nil? && !buildr_project.nil?
        Resgen.warn('Resgen::Build.define_generate_task specifies a target directory parameter but it can be be derived from the context. The parameter should be removed.')
      end

      if target_dir.nil?
        Resgen.error('Resgen::Build.define_generate_task should specify a target directory as it can not be derived from the context.')
      end

      Resgen::GenerateTask.new(repository_key, build_key, generator_keys, target_dir, buildr_project, &block)
    end
  end

  class GenerateTask < Reality::Generators::Rake::BaseGenerateTask
    def initialize(repository_key, key, generator_keys, target_dir, buildr_project = nil)
      super(repository_key, key, generator_keys, target_dir, buildr_project)
    end

    protected

    def default_namespace_key
      :resgen
    end

    def generator_container
      Resgen::Generator
    end

    def instance_container
      Resgen
    end

    def validate_root_element(element)
      element.send(:extension_point, :scan_if_required)
      element.send(:extension_point, :validate)
    end

    def root_element_type
      :repository
    end

    def log_container
      Resgen
    end
  end

  class LoadResourceDescriptor < Reality::Generators::Rake::BaseLoadDescriptor
    protected

    def default_namespace_key
      :resgen
    end

    def log_container
      Resgen
    end

    def pre_load
      Resgen.current_filename = self.filename
    end

    def post_load
      Resgen.current_filename = nil
    end
  end
end
