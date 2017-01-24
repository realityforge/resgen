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
    class AssetDirectory
      IMAGE_EXTENSIONS = %w(.png .gif .jpg .jpeg)

      def pre_init
        @path = "#{self.catalog.path}/#{self.name.gsub('.', '/')}"
        @image_files = {}
      end

      attr_reader :path
      attr_reader :last_updated_at

      def short_name
        self.name.gsub(/^.*\.([^.]+)$/, '\1')
      end

      def image_files
        @image_files.dup
      end

      def image_file_by_key?(key)
        !@image_files[key].nil?
      end

      def image_files?
        !@image_files.empty?
      end

      def scan_if_required
        scan! if scan?
      end

      def validate
        Resgen.error("Asset directory #{self.path} has been removed.") if removed?
        Resgen.error("Asset directory #{self.path} contains no resources.") if !css_files? && !image_files? && !uibinder_files?

        self.css_files.each do |css_file|
          css_file.data_resources.each do |data_resource|
            unless image_file_by_key?(data_resource) || image_file_by_key?(Reality::Naming.underscore(data_resource))
              Resgen.error("Css file #{css_file.filename} contains a data resource '#{data_resource}' that does not align with an image resource named '#{data_resource}' nor '#{Reality::Naming.underscore(data_resource)}' in asset directory '#{self.path}'.")
            end
          end
        end
      end

      def removed?
        !File.exist?(self.path)
      end

      def scan?
        return false if removed?
        (@last_updated_at || 0) < File.mtime(self.path).to_i
      end

      def scan!
        image_files = {}
        stylesheet_names = []
        gss_stylesheet_names = []
        uibinder_names = []

        last_updated_at = File.mtime(self.path).to_i
        Dir["#{self.path}/*"].sort.each do |f|
          f = f.to_s
          next if File.directory?(f)
          extension = File.extname(f)
          if IMAGE_EXTENSIONS.include?(extension)
            image_files[File.basename(f, extension)] = f
          elsif CssFile::EXTENSION == extension
            stylesheet_names << File.basename(f, extension)
          elsif CssFile::GSS_EXTENSION == extension
            gss_stylesheet_names << File.basename(f, extension)
          elsif f.end_with?(UibinderFile::EXTENSION)
            uibinder_names << File.basename(f, UibinderFile::EXTENSION)
          else
            next
          end
          modify_time = File.mtime(f).to_i
          last_updated_at = modify_time if last_updated_at < modify_time
        end

        stylesheet_names.each do |name|
          css_file = css_file_by_name?(name) ? css_file_by_name(name) : css_file(name)
          css_file.type = :css
          css_file.scan_if_required
        end
        gss_stylesheet_names.each do |name|
          css_file = css_file_by_name?(name) ? css_file_by_name(name) : css_file(name)
          css_file.type = :gss
          css_file.scan_if_required
        end
        uibinder_names.each do |name|
          uibinder_file = uibinder_file_by_name?(name) ? uibinder_file_by_name(name) : uibinder_file(name)
          uibinder_file.scan_if_required
          uibinder_file.images.each do |image|
            image_files.delete(File.basename(image.source, File.extname(image.source)))
          end
          uibinder_file.datas.each do |data|
            image_files.delete(File.basename(data.source, File.extname(data.source)))
          end
        end

        @last_updated_at = last_updated_at
        @image_files = image_files
      end
    end
  end
end
