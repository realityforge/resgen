require File.expand_path('../../helper', __FILE__)

class TestCssUtil < Resgen::TestCase
  def test_parse_css_empty_file
    filename = 'myfilename.css'
    results = Resgen::CssUtil.parse_css(filename, '', :css)

    assert_equal filename, results.filename
    assert_equal [], results.css_classes
    assert_equal [], results.data_resources
  end

  def test_parse_css_with_top_level_classes
    filename = 'myfilename.css'
    css_contents = <<CSS
.c1 { cursor: pointer; }
a.c2 { cursor: pointer; }
H.c3 { cursor: pointer; }
H.c4.c5 { cursor: pointer; }
CSS
    results = Resgen::CssUtil.parse_css(filename, css_contents, :css)

    assert_equal filename, results.filename
    assert_equal %w(c1 c2 c3 c4 c5), results.css_classes
    assert_equal [], results.data_resources
  end

  def test_parse_css_with_peer_and_nested_classes
    filename = 'myfilename.css'
    css_contents = <<CSS
.c1, a.c2, H.c3 { cursor: pointer; }
H.c4 > .c5.c6 .c7 > .c8 { cursor: pointer; }
CSS
    results = Resgen::CssUtil.parse_css(filename, css_contents, :css)

    assert_equal filename, results.filename
    assert_equal %w(c1 c2 c3 c4 c5 c6 c7 c8), results.css_classes
    assert_equal [], results.data_resources
  end

  def test_parse_css_with_psuedo_classes
    filename = 'myfilename.css'
    css_contents = <<CSS
.c1:hover, a.c2:last-child, H.c3:first-child { cursor: pointer; }
H.c4:first-child > .c5.c6 .c7:first-child > .c8:first-child { cursor: pointer; }
CSS
    results = Resgen::CssUtil.parse_css(filename, css_contents, :css)

    assert_equal filename, results.filename
    assert_equal %w(c1 c2 c3 c4 c5 c6 c7 c8), results.css_classes
    assert_equal [], results.data_resources
  end

  def test_parse_css_with_elements_intermixed
    filename = 'myfilename.css'
    css_contents = <<CSS
H1 .c1, SPAN a.c2, H.c3 span { cursor: pointer; }
DIV H.c4 > .c5.c6 td .c7 > .c8 TH { cursor: pointer; }
CSS
    results = Resgen::CssUtil.parse_css(filename, css_contents, :css)

    assert_equal filename, results.filename
    assert_equal %w(c1 c2 c3 c4 c5 c6 c7 c8), results.css_classes
    assert_equal [], results.data_resources
  end

  def test_parse_css_with_many_duplicates
    filename = 'myfilename.css'
    css_contents = <<CSS
.c1, .c1.c1, .c1 .c1 span, .c1 > .c1 > .c1 { cursor: pointer; }
CSS
    results = Resgen::CssUtil.parse_css(filename, css_contents, :css)

    assert_equal filename, results.filename
    assert_equal %w(c1), results.css_classes
    assert_equal [], results.data_resources
  end

  def test_parse_css_sorts_classes
    filename = 'myfilename.css'
    css_contents = <<CSS
.c5, .c2.c4, .c3 .c1 span, .c6 > .c1 > .c1 { cursor: pointer; }
CSS
    results = Resgen::CssUtil.parse_css(filename, css_contents, :css)

    assert_equal filename, results.filename
    assert_equal %w(c1 c2 c3 c4 c5 c6), results.css_classes
    assert_equal [], results.data_resources
  end

  def test_parse_traverses_media_clauses
    filename = 'myfilename.css'
    css_contents = <<CSS
.c5 { cursor: pointer; }
@media (min-width: 992px) and (max-width: 1199px) { .c2.c4 { cursor: pointer; } }
.c3 .c1 span { cursor: pointer; }
@media (max-width: 100px) { .c6 > .c1 > .c1 { cursor: pointer; } }
CSS
    results = Resgen::CssUtil.parse_css(filename, css_contents, :css)

    assert_equal filename, results.filename
    assert_equal %w(c1 c2 c3 c4 c5 c6), results.css_classes
    assert_equal [], results.data_resources
  end

  def test_parse_gss
    filename = 'myfilename.gss'
    css_contents = <<CSS
H1 .c5, SPAN a.c2, H.c3 span { cursor: pointer; }
@media (min-width: 992px) and (max-width: 1199px) {DIV H.c6 > .c1.c4 td .c7 .c2 > .c8 TH { cursor: pointer; } }
CSS
    results = Resgen::CssUtil.parse_css(filename, css_contents, :gss)

    assert_equal filename, results.filename
    assert_equal %w(c1 c2 c3 c4 c5 c6 c7 c8), results.css_classes
    assert_equal [], results.data_resources
  end
end
