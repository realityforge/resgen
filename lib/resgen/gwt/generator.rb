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

Resgen::Generator.template_set(:gwt_client_bundle) do |template_set|
  template_set.erb_template([:gwt],
                            :asset_directory,
                            "#{File.dirname(__FILE__)}/templates/client_bundle.java.erb",
                            'main/java/#{asset_directory.gwt.qualified_bundle_name.gsub(".","/")}.java',
                            [Resgen::Gwt::Helper])
end
%w(main test).each do |type|
  Resgen::Generator.template_set(:"gwt_#{type}_qa_support") do |template_set|
    template_set.erb_template([:gwt],
                              :catalog,
                              "#{File.dirname(__FILE__)}/templates/catalog_test_module.java.erb",
                              type + '/java/#{catalog.gwt.qualified_test_module_name.gsub(".","/")}.java',
                              [Resgen::Gwt::Helper])
  end
end
