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

Resgen::FacetManager.facet(:react4j => [:gwt]) do |facet|
  facet.enhance(Resgen::Model::AssetDirectory) do
    def pre_init
      @component_factory_name = nil
    end

    attr_writer :component_factory_name

    def component_factory_name
      @component_factory_name || "#{Reality::Naming.pascal_case(asset_directory.short_name)}Components"
    end

    def qualified_component_factory_name
      "#{asset_directory.name}.#{component_factory_name}"
    end

    java_artifact(:components,
                  :component_factory,
                  :guard => 'asset_directory.data_files.any?{|data_file| data_file.mime_type == "image/svg+xml"}')

  end
end
