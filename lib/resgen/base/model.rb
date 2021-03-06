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

module Resgen
  module Base
    class BaseRepository
      class << self
        include Resgen::ArtifactDSL

        def facet_key
          nil
        end

        def target_key
          :asset_directory
        end
      end

      artifact(:assets, :guard => 'asset_directory.copy_assets_to_target?') do |template_set, facets, helpers, template_options|
        Resgen::Base::CopyAssetsToDirectoryTemplate.new(template_set,
                                                        facets,
                                                        self.target_key,
                                                        'assets',
                                                        'main/java/#{asset_directory.name.gsub(".","/")}',
                                                        helpers,
                                                        template_options)
      end
    end
  end
end
