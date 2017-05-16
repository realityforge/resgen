/* DO NOT EDIT: File is auto-generated */
package iris.planner.resource;

@javax.annotation.Generated( "Resgen" )
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

  @java.lang.SuppressWarnings( "NullableProblems" )
  @javax.annotation.Nonnull
  protected P getPresenter()
  {
    if ( null == _presenter )
    {
      throw new java.lang.IllegalStateException( "Attempting to call getPresenter() when null" );
    }
    else
    {
      return _presenter;
    }
  }
}
