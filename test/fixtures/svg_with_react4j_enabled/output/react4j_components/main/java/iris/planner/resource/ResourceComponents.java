/* DO NOT EDIT: File is auto-generated */
package iris.planner.resource;

@javax.annotation.Generated( "Resgen" )
public final class ResourceComponents
{
  private ResourceComponents()
  {
  }

  @javax.annotation.Nonnull
  public static react4j.ReactNode clock()
  {
    return clock( new react4j.dom.proptypes.html.ImgProps().style( new react4j.dom.proptypes.html.CssProps().height( "1em" ) ) );
  }

  @javax.annotation.Nonnull
  public static react4j.ReactNode clock( @javax.annotation.Nonnull final react4j.dom.proptypes.html.ImgProps props )
  {
    return react4j.dom.DOM.img( props.src( iris.planner.resource.ResourceResources.INSTANCE.clock().getSafeUri().asString() ) );
  }

  @javax.annotation.Nonnull
  public static react4j.ReactNode dotCircle()
  {
    return dotCircle( new react4j.dom.proptypes.html.ImgProps().style( new react4j.dom.proptypes.html.CssProps().height( "1em" ) ) );
  }

  @javax.annotation.Nonnull
  public static react4j.ReactNode dotCircle( @javax.annotation.Nonnull final react4j.dom.proptypes.html.ImgProps props )
  {
    return react4j.dom.DOM.img( props.src( iris.planner.resource.ResourceResources.INSTANCE.dotCircle().getSafeUri().asString() ) );
  }
}
