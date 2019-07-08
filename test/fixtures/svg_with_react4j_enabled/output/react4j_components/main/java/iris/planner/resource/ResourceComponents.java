/* DO NOT EDIT: File is auto-generated */
package iris.planner.resource;

@javax.annotation.Generated( "Resgen" )
@java.lang.SuppressWarnings( "WeakerAccess" )
public final class ResourceComponents
{
  private ResourceComponents()
  {
  }

  @java.lang.FunctionalInterface
  public interface IconPropCustomizerFn
  {
    void customize( @javax.annotation.Nonnull react4j.dom.proptypes.html.ImgProps props );
  }

  @javax.annotation.Nonnull
  public static react4j.ReactNode clock()
  {
    return clock( new react4j.dom.proptypes.html.ImgProps().style( new react4j.dom.proptypes.html.CssProps().height( "1em" ).width( "1em" ) ) );
  }

  @javax.annotation.Nonnull
  public static react4j.ReactNode clock( @javax.annotation.Nonnull final react4j.dom.proptypes.html.ImgProps props )
  {
    return react4j.dom.DOM.img( props.src( iris.planner.resource.ResourceResources.INSTANCE.clock().getSafeUri().asString() ) );
  }

  @javax.annotation.Nonnull
  public static react4j.ReactNode clock( @javax.annotation.Nonnull final IconPropCustomizerFn customizer )
  {
    final react4j.dom.proptypes.html.ImgProps props = new react4j.dom.proptypes.html.ImgProps().style( new react4j.dom.proptypes.html.CssProps().height( "1em" ).width( "1em" ) );
    customizer.customize( props );
    return react4j.dom.DOM.img( props.src( iris.planner.resource.ResourceResources.INSTANCE.clock().getSafeUri().asString() ) );
  }

  @javax.annotation.Nonnull
  public static react4j.ReactNode dotCircle()
  {
    return dotCircle( new react4j.dom.proptypes.html.ImgProps().style( new react4j.dom.proptypes.html.CssProps().height( "1em" ).width( "1em" ) ) );
  }

  @javax.annotation.Nonnull
  public static react4j.ReactNode dotCircle( @javax.annotation.Nonnull final react4j.dom.proptypes.html.ImgProps props )
  {
    return react4j.dom.DOM.img( props.src( iris.planner.resource.ResourceResources.INSTANCE.dotCircle().getSafeUri().asString() ) );
  }

  @javax.annotation.Nonnull
  public static react4j.ReactNode dotCircle( @javax.annotation.Nonnull final IconPropCustomizerFn customizer )
  {
    final react4j.dom.proptypes.html.ImgProps props = new react4j.dom.proptypes.html.ImgProps().style( new react4j.dom.proptypes.html.CssProps().height( "1em" ).width( "1em" ) );
    customizer.customize( props );
    return react4j.dom.DOM.img( props.src( iris.planner.resource.ResourceResources.INSTANCE.dotCircle().getSafeUri().asString() ) );
  }
}
