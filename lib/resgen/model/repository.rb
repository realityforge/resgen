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
  class << self
    def repositories
      repository_map.values
    end

    def repository(name, options = {}, &block)
      Resgen::Model::Repository.new(name, self.current_filename, options, &block)
    end

    def repository_by_name(name)
      repository = repository_map[name.to_s]
      Resgen.error("Unable to locate repository #{name}") unless repository
      repository
    end

    attr_accessor :current_filename

    attr_accessor :current_repository

    private

    def register_repository(name, repository)
      repository_map[name.to_s] = repository
    end

    def repository_map
      @repositories ||= Reality::OrderedHash.new
    end
  end

  module Model #nodoc
    class Repository < Reality::BaseElement
      def initialize(name, filename, options = {}, &block)
        @name, @filename = name, filename
        @asset_directories = Reality::OrderedHash.new

        Resgen.send :register_repository, name, self
        Resgen::FacetManager.target_manager.apply_extension(self)
        Resgen.info 'Repository definition started'
        Resgen.current_repository = self
        super(options, &block)
        Resgen.current_repository = nil
        Resgen.info 'Repository definition completed'
      end

      attr_reader :name
      attr_reader :filename

      def catalog(name, path, options = {}, &block)
        Catalog.new(self, name, path, options, &block)
      end

      def catalog_by_name?(name)
        !!catalog_map[name.to_s]
      end

      def catalog_by_name(name)
        catalog = catalog_map[name.to_s]
        raise "Unable to locate catalog '#{name}' in repository '#{name}'" unless catalog
        catalog
      end

      def catalogs
        catalog_map.values
      end

      def resolve_filename(filename)
        return filename unless self.filename
        filename =~ /^\// ? filename : File.expand_path("#{File.dirname(self.filename)}/#{filename}")
      end

      private

      def register_catalog(catalog)
        raise "Attempting to override existing catalog '#{catalog.name}' in repository '#{self.name}'" if catalog_map[catalog.name.to_s]
        catalog_map[catalog.name.to_s] = catalog
      end

      def catalog_map
        @catalog_map ||= {}
      end
    end
  end
end
