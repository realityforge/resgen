/* DO NOT EDIT: File is auto-generated */
package iris.planner.resource;

@javax.annotation.Generated( "Resgen" )
@java.lang.SuppressWarnings( "PMD.FieldDeclarationsShouldBeAtStartOfClass" )
public abstract class AbstractShiftUI<P extends org.realityforge.gwt.mmvp.Presenter>
  extends iris.planner.resource.AbstractSimpleShiftUI
  implements org.realityforge.gwt.mmvp.View<P>
{
  @javax.annotation.Nullable
  private P _presenter;

  protected AbstractShiftUI()
  {
  }

  protected AbstractShiftUI( final boolean createAndBindUi )
  {
    super( createAndBindUi );
  }

  @Override
  public void bind( @javax.annotation.Nonnull final P presenter )
  {
    if ( null != _presenter )
    {
      unbind();
    }
    _presenter = presenter;
  }

  public void unbind()
  {
    _presenter = null;
  }

  protected boolean isBound()
  {
    return null != _presenter;
  }

  @java.lang.SuppressWarnings( "NullableProblems" )
  @javax.annotation.Nonnull
  protected P getPresenter()
  {
    return java.util.Objects.requireNonNull( _presenter, "Attempting to call getPresenter() when null" );
  }
}
