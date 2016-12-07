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
  class Filters
    def self.include_catalogs(catalog_names)
      catalog_names = catalog_names.is_a?(Array) ? catalog_names : [catalog_names]
      Proc.new { |artifact_type, artifact| is_in_catalogs?(catalog_names, artifact_type, artifact) }
    end

    def self.include_catalog(catalog_name)
      Proc.new { |artifact_type, artifact| is_in_catalog?(catalog_name, artifact_type, artifact) }
    end

    def self.is_in_catalogs?(catalog_names, artifact_type, artifact)
      catalog_names.any? { |catalog_name| is_in_catalog?(catalog_name, artifact_type, artifact) }
    end

    def self.is_in_catalog?(catalog_name, artifact_type, artifact)
      catalog = catalog_for(artifact_type, artifact)
      catalog.nil? || catalog.name.to_s == catalog_name.to_s
    end

    def self.catalog_for(artifact_type, artifact)
      return nil if artifact_type == :repository
      return artifact if artifact_type == :catalog
      return artifact.catalog if artifact_type == :asset_directory
      return artifact.asset_directory.catalog if artifact_type == :css_file
      raise "Unknown artifact type #{artifact_type}"
    end
  end
end