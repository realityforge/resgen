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

    class BadUibinderFile < Exception
    end

    class UibinderField
      def initialize(uibinder_file, name, type, options = {}, &block)
        @type = type
        perform_init(uibinder_file, name, options, &block)
      end

      attr_accessor :type
    end

    class UibinderImage
      def initialize(uibinder_file, name, source, options = {}, &block)
        @source = source
        perform_init(uibinder_file, name, options, &block)
      end

      attr_accessor :source
    end

    class UibinderParameter
      def initialize(uibinder_file, name, type, options = {}, &block)
        @type = type
        perform_init(uibinder_file, name, options, &block)
      end

      attr_accessor :type
    end

    class UibinderStyle
      def initialize(uibinder_file, name, type, css_classes, options = {}, &block)
        @type = type
        @css_classes = css_classes
        perform_init(uibinder_file, name, options, &block)
      end

      attr_accessor :type
      attr_accessor :css_classes

      def validate
        container_type =
          uibinder_file.gwt.cell? ?
            uibinder_file.gwt.qualified_cell_renderer_name :
            uibinder_file.gwt.qualified_abstract_ui_component_name
        expected_style = "#{container_type}.#{Reality::Naming.pascal_case(self.name)}"
        raise "Uibinder style '#{self.name}' in uibinder file '#{uibinder_file.filename}' expected to have a type of '#{expected_style}'" if expected_style != self.type
      end
    end

    class UibinderFile
      EXTENSION = '.ui.xml'

      include SingleFileModel

      def filename
        @filename ||= "#{self.asset_directory.path}/#{self.name}#{EXTENSION}"
      end

      def image(name, source, options = {}, &block)
        UibinderImage.new(self, name, source, options, &block)
      end

      def field(name, type, options = {}, &block)
        UibinderField.new(self, name, type, options, &block)
      end

      def parameter(name, type, options = {}, &block)
        UibinderParameter.new(self, name, type, options, &block)
      end

      def style(name, type, css_classes, options = {}, &block)
        UibinderStyle.new(self, name, type, css_classes, options, &block)
      end

      private

      def validate
        Resgen.error("Uibinder file '#{self.name}' present but gwt facet not enabled") unless facet_enabled?(:gwt)
      end

      def process_file_contents(contents)
        unhandled_fields = field_map.keys.dup
        unhandled_styles = style_map.keys.dup
        unhandled_parameters = parameter_map.keys.dup
        unhandled_images = image_map.keys.dup

        begin
          doc = Nokogiri::XML(contents) do |config|
            config.options = Nokogiri::XML::ParseOptions::STRICT | Nokogiri::XML::ParseOptions::NONET
          end

          package_prefixes = {}

          doc.collect_namespaces.each_pair do |key, url|
            if url.start_with?('urn:import:')
              package_prefixes[key.gsub(/^xmlns\:/, '')] = url.gsub(/^urn\:import\:/, '')
            end
          end

          doc.xpath('//ui:with', 'ui' => 'urn:ui:com.google.gwt.uibinder').each do |with_element|
            name = with_element['field']
            type = with_element['type']
            if parameter_by_name?(name)
              parameter_by_name(name).type = type
            else
              parameter(name, type)
            end
            unhandled_parameters.delete(name)
          end

          doc.xpath('//ui:style[@type]', 'ui' => 'urn:ui:com.google.gwt.uibinder').each do |element|
            name = element['field'] || 'style'
            type = element['type']
            css_fragment = Resgen::CssUtil.parse_css(self.filename, element.text)
            css_classes = css_fragment.css_classes
            if style_by_name?(name)
              style = style_by_name(name)
              style.type = type
              style.css_classes = css_classes
            else
              style(name, type, css_classes)
            end
            unhandled_styles.delete(name)
          end

          doc.xpath('//ui:image[@field]', 'ui' => 'urn:ui:com.google.gwt.uibinder').each do |element|
            name = element['field']
            src = element['src']
            unless image_by_name?(name)
              image(name, src)
            end
            if image_by_name?(name)
              image_by_name(name).source = src
            else
              image(name, src)
            end
            unhandled_images.delete(name)
          end

          doc.xpath('//@ui:field', 'ui' => 'urn:ui:com.google.gwt.uibinder').each do |field_attribute|
            element = field_attribute.parent

            package_name = element.namespace.nil? ? 'com.google.gwt.dom.client' : package_prefixes[element.namespace.prefix]
            classname = element.namespace.nil? ? ELEMENT_NAME_MAP[element.name] : element.name

            name = field_attribute.value
            type = "#{package_name}.#{classname}"

            if field_by_name?(name)
              field_by_name(name).type = type
            else
              field(name, type)
            end
            unhandled_fields.delete(name)
          end

          Resgen.error("Uibinder file '#{self.name}' missing fields #{unhandled_fields.inspect} declared in repository definition.") unless unhandled_fields.empty?
          Resgen.error("Uibinder file '#{self.name}' missing styles #{unhandled_styles.inspect} declared in repository definition.") unless unhandled_styles.empty?
          Resgen.error("Uibinder file '#{self.name}' missing images #{unhandled_images.inspect} declared in repository definition.") unless unhandled_images.empty?
          Resgen.error("Uibinder file '#{self.name}' missing parameters #{unhandled_parameters.inspect} declared in repository definition.") unless unhandled_parameters.empty?
        rescue => e
          raise BadUibinderFile.new(e)
        end
      end

      ELEMENT_NAME_MAP =
        {
          'a' => 'AnchorElement',
          'area' => 'AreaElement',
          'audio' => 'AudioElement',
          'br' => 'BRElement',
          'base' => 'BaseElement',
          'body' => 'BodyElement',
          'button' => 'ButtonElement',
          'canvas' => 'CanvasElement',
          'dl' => 'DListElement',
          'div' => 'DivElement',
          'fieldset' => 'FieldSetElement',
          'form' => 'FormElement',
          'frame' => 'FrameElement',
          'frameset' => 'FrameSetElement',
          'hr' => 'HRElement',
          'head' => 'HeadElement',
          'h1' => 'HeadingElement',
          'h2' => 'HeadingElement',
          'h3' => 'HeadingElement',
          'h4' => 'HeadingElement',
          'h5' => 'HeadingElement',
          'h6' => 'HeadingElement',
          'iframe' => 'IFrameElement',
          'img' => 'ImageElement',
          'input' => 'InputElement',
          'li' => 'LIElement',
          'label' => 'LabelElement',
          'legend' => 'LegendElement',
          'link' => 'LinkElement',
          'map' => 'MapElement',
          'meta' => 'MetaElement',
          'ins' => 'ModElement',
          'del' => 'ModElement',
          'ol' => 'OListElement',
          'object' => 'ObjectElement',
          'optgroup' => 'OptGroupElement',
          'option' => 'OptionElement',
          'p' => 'ParagraphElement',
          'param' => 'ParamElement',
          'pre' => 'PreElement',
          'blockquote' => 'QuoteElement',
          'q' => 'QuoteElement',
          'script' => 'ScriptElement',
          'select' => 'SelectElement',
          'source' => 'SourceElement',
          'span' => 'SpanElement',
          'style' => 'StyleElement',
          'caption' => 'TableCaptionElement',
          'td' => 'TableCellElement',
          'th' => 'TableCellElement',
          'col' => 'TableColElement',
          'colgroup' => 'TableColElement',
          'table' => 'TableElement',
          'tr' => 'TableRowElement',
          'thead' => 'TableSectionElement',
          'tfoot' => 'TableSectionElement',
          'tbody' => 'TableSectionElement',
          'textarea' => 'TextAreaElement',
          'title' => 'TitleElement',
          'ul' => 'UListElement',
          'video' => 'VideoElement',
        }
    end
  end
end
