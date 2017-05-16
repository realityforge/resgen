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

    class CssFile
      EXTENSION = '.css'
      GSS_EXTENSION = '.gss'

      include SingleFileModel

      def pre_init
        @css_classes = []
        @data_resources = {}
        @type = :css
        @last_updated_at = 0
      end

      def filename
        @filename ||= "#{self.asset_directory.path}/#{self.name}.#{self.type}"
      end

      attr_reader :type

      def type=(type)
        Resgen.error("Bad type '#{type}' for CssFile #{self.filename} ") unless [:gss, :css].include?(type)
        @type = type
      end

      attr_reader :css_classes
      attr_reader :data_resources

      def process_file_contents(css_file_contents)
        css_fragment = Resgen::CssUtil.parse_css(self.filename, css_file_contents, self.type)
        @css_classes = css_fragment.css_classes
        @data_resources = css_fragment.data_resources
      end
    end
  end
end
