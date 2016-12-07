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
    attr_writer :bundle_name

    def bundle_name
      @bundle_name || "#{Reality::Naming.pascal_case(asset_directory.short_name)}Resources"
    end

    def qualified_bundle_name
      "#{asset_directory.name}.#{bundle_name}"
    end

    attr_writer :with_lookup

    def with_lookup?
      !!(@with_lookup ||= false)
    end
  end
end
