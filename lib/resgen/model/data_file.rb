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

    class DataFile
      DATA_TYPES = {
        '.woff' => {:mime_type => 'application/font-woff'},
        '.woff2' => {:mime_type => 'font/woff2'},
        '.eot' => {:mime_type => 'application/vnd.ms-fontobject'},
        '.otf' => {:mime_type => 'font/opentype'},
        '.svg' => {:mime_type => 'image/svg+xml'},
        '.ttf' => {:mime_type => 'application/x-font-ttf'}
      }
      DATA_EXTENSIONS = DATA_TYPES.keys

      def initialize(asset_directory, name, filename, options = {}, &block)
        @filename = filename
        data_type_meta = DATA_TYPES[File.extname(self.filename)]
        @embed = data_type_meta ? data_type_meta[:default_embed] : false
        perform_init(asset_directory, name, options, &block)
      end

      attr_writer :embed

      def embed?
        !!@embed
      end

      attr_accessor :filename

      def mime_type
        DATA_TYPES[File.extname(self.filename)][:mime_type]
      end
    end
  end
end
