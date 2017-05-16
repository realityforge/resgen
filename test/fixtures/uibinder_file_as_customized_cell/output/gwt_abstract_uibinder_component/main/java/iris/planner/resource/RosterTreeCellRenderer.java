/* DO NOT EDIT: File is auto-generated */
package iris.planner.resource;

@javax.annotation.Generated( "Resgen" )
@com.google.gwt.uibinder.client.UiTemplate( "RosterTreeCell.ui.xml" )
public interface RosterTreeCellRenderer
  extends com.google.gwt.uibinder.client.UiRenderer
{
  RosterTreeCellRenderer RENDERER = com.google.gwt.core.shared.GWT.create( RosterTreeCellRenderer.class );

  String CELL = "cell";
  String CHECKBOX_FIELD = "checkboxField";

  interface Style
    extends com.google.gwt.resources.client.CssResource
  {
    String icons();
    String rosterCell();
  }

  void render( com.google.gwt.safehtml.shared.SafeHtmlBuilder builder, com.google.gwt.safehtml.shared.SafeHtml checkboxStr, java.lang.String displayString, java.lang.String tooltip, com.google.gwt.safehtml.shared.SafeHtml iconStr );

  com.google.gwt.dom.client.DivElement getCell( com.google.gwt.dom.client.Element parent );

  com.google.gwt.dom.client.DivElement getCheckboxField( com.google.gwt.dom.client.Element parent );

  iris.planner.resource.RosterTreeCellRenderer.Style getStyle();

  void onBrowserEvent( iris.planner.client.view.ui.RosterUI origin, com.google.gwt.dom.client.NativeEvent event, com.google.gwt.dom.client.Element parent, iris.gidgets.client.view.model.TreeNodeViewModel viewModel );
}
