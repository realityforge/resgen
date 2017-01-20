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

      def parse_css(filename, css_file_contents, type)
        css_classes = []
        data_resources = []

        begin
          root = Sass::SCSS::CssParser.new(css_file_contents, filename, nil).parse
        rescue => _
          raise BadCssFile, "Unable to parse CSS file #{filename}"
        end

        root.children.each do |child|
          process_node(child, type, css_classes, data_resources)
        end

        CssFragment.new(filename,
                        :css_classes => css_classes.sort.uniq,
                        :data_resources => data_resources.sort.uniq)
      end

      private

      def process_node(child, type, css_classes, data_resources)
        if child.is_a?(Sass::Tree::RuleNode)
          # Each rule can have a separate comma separate clause
          child.parsed_rules.members.each do |clause|
            clause.members.each do |e|
              parse_candidate(css_classes, e)
            end
          end
        elsif child.is_a?(Sass::Tree::DirectiveNode)
          if child.name == '@media'
            child.children.each do |node|
              process_node(node, type, css_classes, data_resources)
            end
          end
          if :css == type
            if child.name == '@url' && child.value.size > 1
              params = child.value[1].split(' ')
              resource_key = params[1]
              data_resources << resource_key
            end
          elsif :gss == type
            if child.name == '@def' && child.value.size > 1
              params = child.value[1].split(' ')
              resource_key = params[1]
              data_resources << $1 if resource_key =~ /^resourceUrl\("(.*)"\)$/
            end
          end
        end
      end

      def parse_candidate(css_classes, candidate)
        if candidate.is_a?(Sass::Selector::SimpleSequence) || candidate.is_a?(Sass::Selector::Sequence)
          candidate.members.each do |m|
            parse_candidate(css_classes, m)
          end
        elsif candidate.is_a?(Sass::Selector::Class)
          css_classes << candidate.name
        elsif candidate.is_a?(Sass::Selector::Pseudo)
          if candidate.name == 'not' && candidate.arg
            candidate.arg.each do |a|
              parse_candidate(css_classes, a)
            end
          end
        elsif candidate.is_a?(Sass::Selector::Attribute)
          # Skipped
        elsif candidate.is_a?(Sass::Selector::Universal)
          # Skipped
        elsif candidate.is_a?(Sass::Selector::Element)
          # Skipped
        elsif candidate.is_a?(String)
          # Skipped
        else
          Resgen.error("Unhandled css element of type #{candidate.class.name} and value '#{candidate}'")
        end
      end
    end
  end
end
