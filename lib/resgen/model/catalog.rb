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

    class Catalog < Reality::BaseElement
      def initialize(repository, name, path, options = {}, &block)
        @repository, @name, @path = repository, name, path
        @asset_directories = Reality::OrderedHash.new

        repository.send :register_catalog, self
        Resgen::FacetManager.target_manager.apply_extension(self)
        Resgen.info "Catalog '#{name}' definition started"
        super(options, &block)
        Resgen.info "Catalog '#{name}' definition completed"
      end

      attr_reader :repository
      attr_reader :name
      attr_reader :path

      def absolute_path
        @absolute_path ||= self.repository.resolve_filename(self.path)
      end

      def asset_directory(name, options = {}, &block)
        AssetDirectory.new(self, name, options, &block)
      end

      def asset_directory_by_name?(name)
        !!asset_directory_map[name.to_s]
      end

      def asset_directory_by_name(name)
        asset_directory = asset_directory_map[name.to_s]
        raise "Unable to locate asset directory '#{name}' in repository '#{self.name}'" unless asset_directory
        asset_directory
      end

      def asset_directories
        asset_directory_map.values
      end

      private

      def register_asset_directory(asset_directory)
        raise "Attempting to override existing asset directory '#{asset_directory.name}' in repository '#{self.name}'" if asset_directory_map[asset_directory.name.to_s]
        asset_directory_map[asset_directory.name.to_s] = asset_directory
      end

      def asset_directory_map
        @asset_directory_map ||= {}
      end
    end
  end
end
