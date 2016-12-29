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
  module ArtifactDSL
    include Reality::Generators::ArtifactDSL

    def template_set_container
      Resgen::Generator
    end
  end

  module FacetManager
    extend Reality::Facets::FacetContainer
  end

  module Generator #nodoc
    class << self
      include Reality::Generators::TemplateSetContainer

      def derive_default_helpers(options)
        helpers = []
        helpers << Resgen::Gwt::Helper if options[:file_type] == 'java'
        helpers
      end
    end
  end

  module Model #nodoc
  end

  FacetManager.extension_manager.singleton_extension(ArtifactDSL)

  Reality::Model::Repository.new(:Resgen,
                                 Resgen::Model,
                                 :instance_container => Resgen,
                                 :facet_container => Resgen::FacetManager,
                                 :log_container => Resgen) do |r|
    r.model_element(:repository)
    r.model_element(:catalog, :repository, :custom_initialize => true)
    r.model_element(:asset_directory, :catalog)
    r.model_element(:css_file, :asset_directory)
    r.model_element(:uibinder_file, :asset_directory)
    r.model_element(:uibinder_field, :uibinder_file, :access_method => :fields, :inverse_access_method => :field, :custom_initialize => true)
    r.model_element(:uibinder_image, :uibinder_file, :access_method => :images, :inverse_access_method => :image, :custom_initialize => true)
    r.model_element(:uibinder_parameter, :uibinder_file, :access_method => :parameters, :inverse_access_method => :parameter, :custom_initialize => true)
    r.model_element(:uibinder_style, :uibinder_file, :access_method => :styles, :inverse_access_method => :style, :custom_initialize => true)
  end

  Reality::Facets.copy_targets_to_generator_target_manager(Resgen::Generator, Resgen::FacetManager)
end
