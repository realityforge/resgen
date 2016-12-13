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

    class AssetDirectory < Reality::BaseElement
      IMAGE_EXTENSIONS = %w(.png .gif .jpg .jpeg)

      def initialize(catalog, name, options = {}, &block)
        @name = name
        @catalog = catalog
        @filename = "#{catalog.path}/#{name.gsub('.', '/')}"
        @css_files = {}
        @image_files = {}
        self.catalog.send(:register_asset_directory, self)
        Resgen::FacetManager.target_manager.apply_extension(self)
        Resgen.info "AssetDirectory '#{name}' definition started"
        super(options, &block)
        Resgen.info "AssetDirectory '#{name}' definition completed"
      end

      attr_reader :catalog
      attr_reader :name
      attr_reader :filename
      attr_reader :last_updated_at

      def short_name
        self.name.gsub(/^.*\.([^.]+)$/, '\1')
      end

      def css_files
        @css_files.values
      end

      def css_files?
        !@css_files.empty?
      end

      def uibinder_file(name, options = {}, &block)
        filename = "#{self.catalog.absolute_path}/#{self.name.gsub('.', '/')}/#{name}#{UiBinderFile::EXTENSION}"
        UiBinderFile.new(self, name, filename, options, &block)
      end

      def uibinder_file_by_name?(name)
        !!uibinder_file_map[name.to_s]
      end

      def uibinder_file_by_name(name)
        uibinder_file = uibinder_file_map[name.to_s]
        Resgen.error("Unable to locate uibinderfile named '#{name}'") unless uibinder_file
        uibinder_file
      end

      def uibinder_files
        uibinder_file_map.values
      end

      def uibinder_files?
        !uibinder_file_map.empty?
      end

      def image_files
        @image_files.dup
      end

      def image_files?
        !@image_files.empty?
      end

      def scan_if_required
        scan! if scan?
      end

      def validate
        Resgen.error("Asset directory #{self.filename} has been removed.") if removed?
        Resgen.error("Asset directory #{self.filename} contains no resources.") if !css_files? && !image_files? && !uibinder_files?
      end

      def removed?
        !File.exist?(self.filename)
      end

      def scan?
        return false if removed?
        (@last_updated_at || 0) < File.mtime(self.filename).to_i
      end

      def scan!
        image_files = {}
        stylesheet_filenames = {}
        uibinder_filenames = {}

        last_updated_at = File.mtime(self.filename).to_i
        Dir["#{self.filename}/*"].sort.each do |f|
          f = f.to_s
          next if File.directory?(f)
          extension = File.extname(f)
          if IMAGE_EXTENSIONS.include?(extension)
            image_files[File.basename(f, extension)] = f
          elsif CssFile::EXTENSION == extension
            stylesheet_filenames[File.basename(f, extension)] = f
          elsif f.end_with?(UiBinderFile::EXTENSION)
            uibinder_filenames[File.basename(f, UiBinderFile::EXTENSION)] = f
          else
            next
          end
          modify_time = File.mtime(f).to_i
          last_updated_at = modify_time if last_updated_at < modify_time
        end

        css_files = {}
        stylesheet_filenames.each_pair do |name, filename|
          css_files[name] = @css_files[name].nil? ? CssFile.new(self, name, filename) : @css_files[name]
          css_files[name].scan! if css_files[name].scan?
        end
        uibinder_filenames.each_pair do |name, filename|
          uibinder_file =
            uibinder_file_by_name?(name) ? uibinder_file_by_name(name) : UiBinderFile.new(self, name, filename)
          uibinder_file.scan_if_required
        end

        @last_updated_at = last_updated_at
        @image_files = image_files
        @css_files = css_files
      end

      private

      def uibinder_file_map
        (@uibinder_file_map ||= {})
      end

      def register_uibinder_file(uibinder_file)
        Resgen.error("Asset directory #{self.filename} attempting to register duplicate uibinder_file with name '#{uibinder_file.name}'.") if uibinder_file_map[name.to_s]
        uibinder_file_map[uibinder_file.name.to_s] = uibinder_file
      end
    end
  end
end
