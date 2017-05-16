Resgen.repository(:Planner) do |repository|
  repository.enable_facet(:gwt)

  repository.catalog(:Planner, 'src/main/java') do |catalog|
    catalog.asset_directory('iris.planner.resource') do |d|
      d.uibinder_file('RosterTreeCell') do |f|
        f.gwt.cell_context ='iris.planner.client.view.ui.RosterUI'
        f.gwt.event_handler_parameter(:ViewModel, 'iris.gidgets.client.view.model.TreeNodeViewModel')
      end
    end
  end
end
