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

module Resgen # nodoc
  class GenUtil
    def self.output_filter
      Proc.new do |content|
        unless content.include?("DO NOT EDIT: File is auto-generated")
          puts("Generator for template #{template_filename} failed to generate content containing text 'DO NOT EDIT: File is auto-generated'")
          # Domgen.error("Generator for template #{template_filename} failed to generate content containing text 'DO NOT EDIT: File is auto-generated'")
        end
        content
      end
    end
  end
end
