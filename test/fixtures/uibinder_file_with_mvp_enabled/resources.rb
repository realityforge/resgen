Resgen.repository(:Planner) do |repository|
  #repository.enable_facets(:gwt)
  repository.enable_facets(:gwt, :mvp)

  repository.catalog(:Planner, 'src/main/java') do |catalog|
    catalog.asset_directory('iris.planner.resource')
  end
end
