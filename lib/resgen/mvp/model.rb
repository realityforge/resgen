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

Resgen::FacetManager.facet(:mvp => [:gwt]) do |facet|
  facet.enhance(Resgen::Model::UibinderFile) do
    def pre_init
      @abstract_ui_component_name = nil
    end

    attr_writer :abstract_ui_component_name

    def abstract_ui_component_name
      @abstract_ui_component_name || "Abstract#{uibinder_file.name}"
    end

    def qualified_abstract_ui_component_name
      "#{uibinder_file.asset_directory.name}.#{abstract_ui_component_name}"
    end

    java_artifact(:abstract_uibinder_component,
                  :abstract_ui_component,
                  :output_filter => Resgen::GenUtil.output_filter,
                  :guard => '!uibinder_file.gwt.cell?')
  end
end
