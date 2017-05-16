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

    # Module to be included for resources that are derived from a single file on the filesystem
    # It is expected that the class including this module implements the methods
    # * filename(): Should return the name of the filename to process.
    # * process_file_contents(contents): Should handle parsing and interpreting file.
    module SingleFileModel
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

        process_file

        @last_updated_at = last_updated_at
      end

      def process_file
        process_file_contents(IO.read(self.filename))
      end
    end
  end
end
