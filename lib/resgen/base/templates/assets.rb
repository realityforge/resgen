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

module Resgen
  module Base
    class CopyAssetsToDirectoryTemplate < Reality::Generators::Template
      attr_reader :output_directory_pattern

      def initialize(template_set, facets, target, template_key, output_directory_pattern, helpers = [], options = {})
        super(template_set, facets, target, template_key, helpers, options)
        @output_directory_pattern = output_directory_pattern
      end

      def output_path
        self.output_directory_pattern
      end

      protected

      def generate!(target_basedir, element, unprocessed_files)
        object_name = name_for_element(element)
        render_context = create_context(element)
        context_binding = render_context.context_binding
        begin
          output_directory = eval("\"#{self.output_directory_pattern}\"", context_binding, "#{self.template_key}#Filename")
          output_directory = File.join(target_basedir, output_directory)

          FileUtils.mkdir_p output_directory unless File.directory?(output_directory)

          element.css_files.each do |css_file|
            copy_file(element, css_file, output_directory, unprocessed_files)
          end
          element.data_files.each do |css_file|
            copy_file(element, css_file, output_directory, unprocessed_files)
          end
          element.image_files.each do |css_file|
            copy_file(element, css_file, output_directory, unprocessed_files)
          end

          # Note: uibinder and all internal assets (images && data resources) are not copied
          # Only as no demand for this scenario has arisen
        rescue => e
          raise Reality::Generators::GeneratorError.new("Error generating #{self.name} for #{self.target} #{object_name} due to '#{e}'", e)
        end
      end

      def copy_file(asset_directory, element, output_directory, unprocessed_files)
        local_filename = File.basename(element.filename)
        from = File.expand_path("#{asset_directory.path}/#{local_filename}")
        to = File.expand_path("#{output_directory}/#{local_filename}")
        if File.exist?(to) && IO.read(to) == IO.read(from)
          Reality::Generators.debug "Skipping copy of #{from} to #{to} as it is uptodate"
        else
          Reality::Generators.debug "Copying #{from} to #{to}"
          FileUtils.cp from, to
        end
        unprocessed_files.delete(to)
      end
    end
  end
end
