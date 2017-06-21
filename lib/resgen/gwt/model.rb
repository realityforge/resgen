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

Resgen::FacetManager.facet(:gwt) do |facet|
  facet.enhance(Resgen::Model::AssetDirectory) do
    def pre_init
      @bundle_name = nil
      @with_lookup = false
    end

    attr_writer :bundle_name

    def bundle_name
      @bundle_name || "#{Reality::Naming.pascal_case(asset_directory.short_name)}Resources"
    end

    def qualified_bundle_name
      "#{asset_directory.name}.#{bundle_name}"
    end

    attr_writer :with_lookup

    def with_lookup?
      !!@with_lookup
    end

    java_artifact(:client_bundle,
                  :bundle,
                  :guard => 'asset_directory.css_files? || asset_directory.image_files?')
  end

  facet.enhance(Resgen::Model::NoftConfigFile) do
    def pre_init
      @icon_stamp_name = nil
    end

    attr_writer :icon_stamp_name

    def icon_stamp_name
      @icon_stamp_name || "#{Reality::Naming.pascal_case(noft_config_file.name)}Icons"
    end

    def qualified_icon_stamp_name
      "#{noft_config_file.asset_directory.name}.#{icon_stamp_name}"
    end

    java_artifact(:svg_icons, :icon_stamp)
  end

  facet.enhance(Resgen::Model::UibinderFile) do
    def pre_init
      @cell = nil
      @cell_context = nil
      @event_handler = false
      @event_handler_parameter = {}
      @cell_renderer_name = nil
      @abstract_ui_component_name = nil
    end

    attr_writer :cell

    def cell?
      @cell.nil? ? uibinder_file.name.end_with?('Cell') : !!@cell
    end

    def cell_context
      Resgen.error("Attempted to invoke UibinderFile.gwt.cell_context on '#{uibinder_file.name}' but file is not a cell.") unless cell?
      @cell_context || self.qualified_cell_name
    end

    def cell_context=(cell_context)
      self.event_handler = true
      @cell_context = cell_context
    end

    def event_handler=(event_handler)
      self.cell = true
      @event_handler = !!event_handler
    end

    def event_handler?
      !!@event_handler
    end

    def event_handler_parameter(name, type)
      self.event_handler = true
      event_handler_parameters[name] = type
    end

    def event_handler_parameters
      @event_handler_parameter
    end

    attr_writer :cell_renderer_name

    def cell_renderer_name
      Resgen.error("Attempted to invoke UibinderFile.gwt.cell_renderer_name on '#{uibinder_file.name}' but file is not a cell.") unless cell?
      @cell_renderer_name || "#{uibinder_file.name}Renderer"
    end

    def qualified_cell_renderer_name
      "#{uibinder_file.asset_directory.name}.#{cell_renderer_name}"
    end

    def qualified_cell_name
      "#{uibinder_file.asset_directory.name}.#{cell_renderer_name.gsub(/Renderer$/,'')}"
    end

    attr_writer :abstract_ui_component_name

    def abstract_ui_component_name
      @abstract_ui_component_name || "Abstract#{uibinder_file.mvp? ? 'Simple' : ''}#{uibinder_file.name}"
    end

    def qualified_abstract_ui_component_name
      "#{uibinder_file.asset_directory.name}.#{abstract_ui_component_name}"
    end

    def qualified_ui_component_name
      qualified_abstract_ui_component_name.gsub(/(.*)\.Abstract#{uibinder_file.mvp? ? 'Simple' : ''}([^.]+)$/, '\1.\2')
    end

    def qualified_concrete_component_name
      qualified_abstract_ui_component_name.gsub(/(.*)\.Abstract#{uibinder_file.mvp? ? 'Simple' : ''}([^.]+)$/, '\1.\2')
    end

    java_artifact(:abstract_uibinder_component,
                  :abstract_ui_component,
                  :guard => '!uibinder_file.gwt.cell?')
    java_artifact(:abstract_uibinder_component,
                  :cell_renderer,
                  :guard => 'uibinder_file.gwt.cell?')
  end
end
