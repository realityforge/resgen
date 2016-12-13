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
  module FacetManager
    extend Reality::Facets::FacetContainer
  end

  FacetManager.target_manager.target(Resgen::Model::Repository, :repository)
  FacetManager.target_manager.target(Resgen::Model::Catalog, :catalog, :repository)
  FacetManager.target_manager.target(Resgen::Model::AssetDirectory, :asset_directory, :catalog)
  FacetManager.target_manager.target(Resgen::Model::CssFile, :css_file, :asset_directory)
  FacetManager.target_manager.target(Resgen::Model::UiBinderFile, :uibinder_file, :asset_directory)
  FacetManager.target_manager.target(Resgen::Model::UiBinderField, :uibinder_field, :uibinder_file, :access_method => 'fields', :inverse_access_method => 'field')
  FacetManager.target_manager.target(Resgen::Model::UiBinderParameter, :uibinder_parameter, :uibinder_file, :access_method => 'parameters', :inverse_access_method => 'parameter')
  FacetManager.target_manager.target(Resgen::Model::UiBinderStyle, :uibinder_style, :uibinder_file, :access_method => 'styles', :inverse_access_method => 'style')
end
