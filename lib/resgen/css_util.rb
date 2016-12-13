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
  module CssUtil
    class BadCssFile < Exception
    end

    class << self
      class CssFragment < Reality::BaseElement
        def initialize(filename, options = {}, &block)
          @filename = filename
          @css_classes = Reality::OrderedHash.new
          @data_resources = Reality::OrderedHash.new
          super(options, &block)
        end

        attr_reader :filename
        attr_accessor :css_classes
        attr_accessor :data_resources
      end

      def parse_css(filename, css_file_contents)
        css_classes = []
        data_resources = []

        begin
          root = Sass::SCSS::CssParser.new(css_file_contents, filename, nil).parse
        rescue => _
          raise BadCssFile, "Unable to parse CSS file #{filename}"
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

        root.children.each do |child|
          next unless child.is_a?(Sass::Tree::DirectiveNode)
          next unless child.name == '@url' && child.value.size > 1
          params = child.value[1].split(' ')
          resource_key = params[1]
          data_resources << resource_key
        end

        CssFragment.new(filename,
                        :css_classes => css_classes.sort.uniq,
                        :data_resources => data_resources.sort.uniq)
      end
    end
  end
end
