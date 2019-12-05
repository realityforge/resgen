/* DO NOT EDIT: File is auto-generated */
package iris.planner.resource;

@javax.annotation.Generated( "Resgen" )
@java.lang.SuppressWarnings( { "PMD.FieldDeclarationsShouldBeAtStartOfClass", "PMD.ConstructorCallsOverridableMethod", "rawtypes" } )
@edu.umd.cs.findbugs.annotations.SuppressFBWarnings( "PCOA_PARTIALLY_CONSTRUCTED_OBJECT_ACCESS" )
public abstract class AbstractSimpleShiftUI
  implements com.google.gwt.user.client.ui.IsWidget
{
  protected static final String GRID_PANEL = "_gridPanel";
  protected static final String FIXED_GRID = "_fixedGrid";
  protected static final String SCROLL_GRID = "_scrollGrid";

  public interface Style
    extends com.google.gwt.resources.client.CssResource
  {
    @ClassName( "action" )
    String action();
    @ClassName( "activeShift" )
    String activeShift();
    @ClassName( "canDrop" )
    String canDrop();
    @ClassName( "column" )
    String column();
    @ClassName( "fixedTable" )
    String fixedTable();
    @ClassName( "header" )
    String header();
    @ClassName( "hiddenRow" )
    String hiddenRow();
    @ClassName( "icon" )
    String icon();
    @ClassName( "pending" )
    String pending();
    @ClassName( "stripe" )
    String stripe();
    @ClassName( "text" )
    String text();
    @ClassName( "tooltip" )
    String tooltip();
  }

  @com.google.gwt.uibinder.client.UiTemplate( "ShiftUI.ui.xml" )
  interface Binder
    extends com.google.gwt.uibinder.client.UiBinder<com.google.gwt.user.client.ui.Widget, iris.planner.resource.ShiftUI>
  {
  }

  private static final Binder UI_BINDER = com.google.gwt.core.client.GWT.create( Binder.class );

  private com.google.gwt.user.client.ui.Widget _widget;
  @com.google.gwt.uibinder.client.UiField
  com.google.gwt.user.client.ui.LayoutPanel _gridPanel;
  @com.google.gwt.uibinder.client.UiField
  iris.gidgets.client.view.ui.data_grid.ScrollingDataGrid _fixedGrid;
  @com.google.gwt.uibinder.client.UiField
  iris.gidgets.client.view.ui.data_grid.ScrollingDataGrid _scrollGrid;
  @com.google.gwt.uibinder.client.UiField
  iris.planner.resource.AbstractSimpleShiftUI.Style style;
  @com.google.gwt.uibinder.client.UiField
  com.google.gwt.resources.client.ImageResource stripe;

  protected AbstractSimpleShiftUI()
  {
    this( true );
  }

  protected AbstractSimpleShiftUI( final boolean createAndBindUi )
  {
    if ( createAndBindUi )
    {
      createAndBindUi();
    }
  }

  @java.lang.Override
  public com.google.gwt.user.client.ui.Widget asWidget()
  {
    return _widget;
  }

  protected void createAndBindUi()
  {
    _widget = UI_BINDER.createAndBindUi( (iris.planner.resource.ShiftUI) this );
    style.ensureInjected();
  }
}
