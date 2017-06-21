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
      def pre_init
        @path = nil
        @copy_assets_to_target = false
        @last_updated_at = 0
      end

      def path=(path)
        @path = "#{self.catalog.path}/#{path}"
      end

      def path
        @path || "#{self.catalog.path}/#{self.name.gsub('.', '/')}"
      end

      attr_reader :last_updated_at

      def short_name
        self.name.gsub(/^.*\.([^.]+)$/, '\1')
      end

      def image_file(name, filename, options = {}, &block)
        ImageFile.new(self, name, filename, options, &block)
      end

      def data_file(name, filename, options = {}, &block)
        DataFile.new(self, name, filename, options, &block)
      end

      attr_writer :copy_assets_to_target

      def copy_assets_to_target?
        !!@copy_assets_to_target
      end

      def scan_if_required
        scan! if scan?
      end

      def validate
        Resgen.error("Asset directory '#{self.path}' has been removed.") if removed?
        Resgen.error("Asset directory '#{self.path}' contains no resources.") if !css_files? && !image_files? && !uibinder_files? && !noft_config_files?

        self.css_files.each do |css_file|
          css_file.data_resources.each do |data_resource|
            underscore_name = Reality::Naming.underscore(data_resource)
            unless image_file_by_name?(data_resource) || image_file_by_name?(underscore_name) || data_file_by_name?(data_resource) || data_file_by_name?(underscore_name)
              Resgen.error("Css file #{css_file.filename} contains a data resource '#{data_resource}' that does not align with an image resource or data resource named '#{data_resource}' nor '#{underscore_name}' in asset directory '#{self.path}'.")
            end
          end
        end
      end

      def removed?
        !File.exist?(self.path)
      end

      def scan?
        return false if removed?
        @last_updated_at < File.mtime(self.path).to_i
      end

      def scan!
        image_file_names = {}
        data_file_names = {}
        stylesheet_names = []
        noft_config_filenames = []
        gss_stylesheet_names = []
        uibinder_names = []

        last_updated_at = File.mtime(self.path).to_i
        Dir["#{self.path}/*"].sort.each do |f|
          f = File.expand_path(f.to_s)
          next if File.directory?(f)
          extension = File.extname(f)
          if ImageFile::IMAGE_EXTENSIONS.include?(extension)
            image_file_names[File.basename(f, extension)] = f
          elsif DataFile::DATA_EXTENSIONS.include?(extension)
            data_file_names[File.basename(f, extension)] = f
          elsif f =~ /#{Regexp.escape(NoftConfigFile::EXTENSION)}$/
            noft_config_filenames << File.basename(f, NoftConfigFile::EXTENSION)
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
            image_file_names.delete(File.basename(image.source, File.extname(image.source)))
          end
          uibinder_file.datas.each do |data|
            image_file_names.delete(File.basename(data.source, File.extname(data.source)))
          end
          uibinder_file.datas.each do |data|
            data_file_names.delete(File.basename(data.source, File.extname(data.source)))
          end
        end
        noft_config_filenames.each do |noft_config_file_name|
          data_file_names.delete(noft_config_file_name)
        end

        image_file_names.each_pair do |image_file_name, filename|
          image_file = image_file_by_name?(image_file_name) ?
            image_file_by_name(image_file_name) :
            image_file(image_file_name, filename)
          image_file.filename = filename
        end
        data_file_names.each_pair do |data_file_name, filename|
          data_file = data_file_by_name?(data_file_name) ?
            data_file_by_name(data_file_name) :
            data_file(data_file_name, filename)
          data_file.filename = filename
        end
        noft_config_filenames.each do |noft_config_name|
          noft_config_file(noft_config_name) unless noft_config_file_by_name?(noft_config_name)
        end

        @last_updated_at = last_updated_at
      end
    end
  end
end
