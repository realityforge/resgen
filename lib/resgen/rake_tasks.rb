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

    class << self
      include Reality::Generators::Rake::BuildTasksMixin

      def default_descriptor_filename
        DEFAULT_RESOURCES_FILENAME
      end

      def generated_type_path_prefix
        :resgen
      end

      def root_element_type
        :repository
      end

      def log_container
        Resgen
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

    class LoadDescriptor < Reality::Generators::Rake::BaseLoadDescriptor
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
end
