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

    class BadUiBinderFile < Exception
    end

    class UiBinderField < Reality::BaseElement
      def initialize(uibinder_file, name, type, options = {}, &block)
        @uibinder_file = uibinder_file
        @name = name
        @type = type
        Resgen::FacetManager.target_manager.apply_extension(self)
        uibinder_file.send(:register_field, self)
        Resgen.info "UiBinderField '#{name}' definition started"
        super(options, &block)
        Resgen.info "UiBinderField '#{name}' definition completed"
      end

      attr_reader :uibinder_file
      attr_reader :name
      attr_reader :type
    end

    class UiBinderParameter < Reality::BaseElement
      def initialize(uibinder_file, name, type, options = {}, &block)
        @uibinder_file = uibinder_file
        @name = name
        @type = type
        Resgen::FacetManager.target_manager.apply_extension(self)
        uibinder_file.send(:register_parameter, self)
        Resgen.info "UiBinderParameter '#{name}' definition started"
        super(options, &block)
        Resgen.info "UiBinderParameter '#{name}' definition completed"
      end

      attr_reader :uibinder_file
      attr_reader :name
      attr_accessor :type
    end

    class UiBinderStyle < Reality::BaseElement
      def initialize(uibinder_file, name, type, css_classes, options = {}, &block)
        @uibinder_file = uibinder_file
        @name = name
        @type = type
        @css_classes = css_classes

        Resgen::FacetManager.target_manager.apply_extension(self)
        uibinder_file.send(:register_style, self)
        Resgen.info "UiBinderStyle '#{name}' definition started"
        super(options, &block)
        Resgen.info "UiBinderStyle '#{name}' definition completed"
      end

      attr_reader :uibinder_file
      attr_reader :name
      attr_reader :type
      attr_reader :css_classes

      def validate
        expected_style = "#{uibinder_file.gwt.qualified_abstract_ui_component_name}.#{Reality::Naming.pascal_case(self.name)}"
        raise "Uibinder style '#{self.name}' in uibinder file '#{uibinder_file.filename}' expected to have a type of '#{expected_style}'" if expected_style != self.type
      end

    end

    class UiBinderFile < SingleFileModel
      EXTENSION = '.ui.xml'

      def initialize(asset_directory, name, filename, options = {}, &block)
        @asset_directory = asset_directory
        @name = name
        @fields = {}
        @css_classes = []

        asset_directory.send(:register_uibinder_file, self)
        Resgen.info "UiBinderFile '#{name}' definition started"
        super(filename, options, &block)
        Resgen.info "UiBinderFile '#{name}' definition completed"
      end

      attr_reader :asset_directory
      attr_reader :name

      def field(name, type, options = {}, &block)
        UiBinderField.new(self, name, type, options, &block)
      end

      def field_by_name?(name)
        !!field_map[name.to_s]
      end

      def field_by_name(name)
        field = field_map[name.to_s]
        Resgen.error("Unable to locate field '#{name}' in uibinder file '#{self.name}'") unless field
        field
      end

      def fields
        field_map.values
      end

      def parameter(name, type, options = {}, &block)
        UiBinderParameter.new(self, name, type, options, &block)
      end

      def parameter_by_name?(name)
        !!parameter_map[name.to_s]
      end

      def parameter_by_name(name)
        parameter = parameter_map[name.to_s]
        Resgen.error("Unable to locate parameter '#{name}' in uibinder file '#{self.name}'") unless parameter
        parameter
      end

      def parameters
        parameter_map.values
      end

      def style(name, type, css_classes, options = {}, &block)
        UiBinderStyle.new(self, name, type, css_classes, options, &block)
      end

      def style_by_name?(name)
        !!style_map[name.to_s]
      end

      def style_by_name(name)
        style = style_map[name.to_s]
        Resgen.error("Unable to locate style '#{name}' in uibinder file '#{self.name}'") unless style
        style
      end

      def styles
        style_map.values
      end

      private

      def validate
        Resgen.error("Uibinder file '#{self.name}' present but gwt facet not enabled") unless facet_enabled?(:gwt)
      end

      def register_field(field)
        Resgen.error("Attempting to override existing field '#{field.name}' in uibinder file '#{self.name}'") if field_map[field.name.to_s]
        field_map[field.name.to_s] = field
      end

      def register_parameter(parameter)
        Resgen.error("Attempting to override existing parameter '#{parameter.name}' in uibinder file '#{self.name}'") if parameter_map[parameter.name.to_s]
        parameter_map[parameter.name.to_s] = parameter
      end

      def register_style(style)
        Resgen.error("Attempting to override existing style '#{style.name}' in uibinder file '#{self.name}'") if style_map[style.name.to_s]
        style_map[style.name.to_s] = style
      end

      def style_map
        @style_map ||= {}
      end

      def parameter_map
        @parameter_map ||= {}
      end

      def field_map
        @field_map ||= {}
      end

      def process_file_contents(contents)
        unhandled_fields = field_map.keys
        unhandled_styles = style_map.keys
        unhandled_parameters = parameter_map.keys

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
            key = element['field'] || 'style'
            type = element['type']
            css_fragment = Resgen::CssUtil.parse_css(self.filename, element.text)
            css_classes = css_fragment.css_classes
            if style_by_name?(name)
              style = style_by_name(name)
              style.type = type
              style.css_classes = css_classes
            else
              style(key, type, css_classes)
            end
            unhandled_styles.delete(name)
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
          Resgen.error("Uibinder file '#{self.name}' missing parameters #{unhandled_parameters.inspect} declared in repository definition.") unless unhandled_parameters.empty?
        rescue => e
          raise BadUiBinderFile.new(e)
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
