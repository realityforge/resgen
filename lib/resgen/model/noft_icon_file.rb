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

    class NoftIconFile

      def initialize(noft_config_file, name, filename, options = {}, &block)
        @filename = filename
        @last_updated_at = 0
        perform_init(noft_config_file, name, options, &block)
      end

      def svg_content
        content = IO.read(self.filename)
        content = content.gsub(' xmlns="http://www.w3.org/2000/svg"','')
        content
      end

      attr_accessor :filename

      attr_accessor :noft_icon

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

        @last_updated_at = last_updated_at
      end

      def validate
        Resgen.error("Noft icon file '#{self.filename}' has been removed.") if removed?
      end
    end
  end
end
