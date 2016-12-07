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
  module Generator #nodoc
    module ResgenGenerator
      class << self
        include Reality::Generators::Generator
      end
    end

    class << self
      include Reality::Generators::TemplateSetContainer

      protected

      def new_template_set(name, options, &block)
        Resgen::Generator::TemplateSet.new(self, name.to_s, options, &block)
      end

      def new_generator
        Resgen::Generator::ResgenGenerator
      end
    end

    class TemplateSet < Reality::Generators::TemplateSet
      def erb_template(facets, target, template_filename, output_filename_pattern, helpers = [], options = {})
        Reality::Generators::ErbTemplate.new(self, facets, target.to_sym, template_filename, output_filename_pattern, helpers, options)
      end

      def ruby_template(facets, target, template_filename, output_filename_pattern, helpers = [], options = {})
        Reality::Generators::RubyTemplate.new(self, facets, target.to_sym, template_filename, output_filename_pattern, helpers, options)
      end
    end
  end
end

Resgen::FacetManager.target_manager.targets.each do |target|
  Resgen::Generator.target_manager.target(target.key, target.container_key, :access_method => target.access_method)
end
