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

    class BadCssFile < Exception
    end

    class CssFile < Reality::BaseElement
      def initialize(name, filename, options = {}, &block)
        super(options, &block)
        @name, @filename = name, filename
        @css_classes = []
      end

      attr_reader :name
      attr_reader :filename
      attr_reader :css_classes
      attr_reader :last_updated_at

      def removed?
        !File.exist?(self.filename)
      end

      def scan?
        return false if removed?
        (@last_updated_at || 0) < File.mtime(self.filename).to_i
      end

      def scan!
        css_file_contents = IO.read(self.filename)
        last_updated_at = File.mtime(self.filename).to_i

        css_classes = []

        begin
          root = Sass::SCSS::CssParser.new(css_file_contents, self.filename, nil).parse
        rescue => e
          raise BadCssFile, "Unable to parse CSS file #{self.filename}"
        end

        root.children.each do |child|
          next unless child.is_a?(Sass::Tree::RuleNode)
          # Each rule can have a separate comma separate clause
          child.parsed_rules.members.each do |clause|
            clause.members.each do |e|

              # e can be a separate classifier chain ala input.a.b
              e.to_s.split('.')[1...100000].each do |classname|
                css_classes << classname
              end
            end
          end
        end

        @last_updated_at = last_updated_at
        @css_classes = css_classes.sort.uniq
      end
    end
  end
end
