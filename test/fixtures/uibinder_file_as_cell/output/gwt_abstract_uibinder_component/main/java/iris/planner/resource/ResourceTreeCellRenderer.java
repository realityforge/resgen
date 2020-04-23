/* DO NOT EDIT: File is auto-generated */
package iris.planner.resource;

@javax.annotation.Generated( "Resgen" )
@com.google.gwt.uibinder.client.UiTemplate( "ResourceTreeCell.ui.xml" )
@java.lang.SuppressWarnings( "rawtypes" )
public interface ResourceTreeCellRenderer
  extends com.google.gwt.uibinder.client.UiRenderer
{
  ResourceTreeCellRenderer RENDERER = com.google.gwt.core.shared.GWT.create( ResourceTreeCellRenderer.class );

  interface Style
    extends com.google.gwt.resources.client.CssResource
  {
    String duty();
    String icon();
    String rest();
    String travel();
  }

  void render( com.google.gwt.safehtml.shared.SafeHtmlBuilder builder, java.lang.String displayString, java.lang.String textCss, java.lang.String cellCss, com.google.gwt.safehtml.shared.SafeHtml iconStr );

  iris.planner.resource.ResourceTreeCellRenderer.Style getStyle();
}
