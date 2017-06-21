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

    class NoftConfigFile
      EXTENSION = '.noft.json'

      def pre_init
        @filename = File.expand_path("#{name}#{EXTENSION}", asset_directory.path)
        @last_updated_at = 0
        @icon_names_filter = []
      end

      def icon(name, filename, options = {}, &block)
        NoftIconFile.new(self, name, filename, options, &block)
      end

      attr_accessor :icon_names_filter

      attr_accessor :filename

      attr_reader :last_updated_at

      def scan_if_required
        scan! if scan?
      end

      def removed?
        !File.exist?(self.filename)
      end

      def scan?
        return false if removed?
        @last_updated_at < File.mtime(self.filename).to_i
      end

      def scan!
        last_updated_at = File.mtime(self.filename).to_i

        require 'noft'
        filter = self.icon_names_filter.empty? ? nil : self.icon_names_filter
        Noft.read_model(self.filename, filter).tap do |s|
          s.icons.each do |icon|
            self.icon(icon.name, "#{self.asset_directory.path}/#{icon.name}.svg", :noft_icon => icon)
          end
        end

        @last_updated_at = last_updated_at
      end

      def validate
        Resgen.error("Noft config file '#{self.filename}' has been removed.") if removed?
        Resgen.error("Noft config file '#{self.filename}' contains no icons.") unless icons?
      end
    end
  end
end
