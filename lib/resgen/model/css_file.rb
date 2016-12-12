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
  module Model #nodoc

    class CssFile < SingleFileModel
      EXTENSION = '.css'

      def initialize(asset_directory, name, filename, options = {}, &block)
        @asset_directory = asset_directory
        @name = name
        @css_classes = []

        Resgen.info "CssFile '#{name}' definition started"
        super(filename, options, &block)
        Resgen.info "CssFile '#{name}' definition completed"
      end

      attr_reader :asset_directory
      attr_reader :name
      attr_reader :css_classes

      def process_file_contents(css_file_contents)
        @css_classes = Resgen::CssUtil.extract_css_classes(self.filename, css_file_contents)
      end
    end
  end
end
