Resgen.repository(:Planner) do |repository|
  repository.enable_facet(:gwt)

  repository.catalog(:Planner, 'src/main/java') do |catalog|
    catalog.asset_directory('iris.planner.resource', 'gwt.with_lookup' => true)
  end
end
