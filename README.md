# resgen

[![Build Status](https://api.travis-ci.com/realityforge/resgen.svg?branch=master)](http://travis-ci.com/realityforge/resgen)

Resgen is a ruby library that helps you to generate gwt component interfaces from assets.

Visit the [Resgen site](http://realityforge.org/resgen/) for further details.

## TODO

* Add tests for the model objects.
* Figure out how to remove `Resgen.current_filename` and setting in `LoadDescriptor` and push this back
  to mda so all elements generated from files have ability to resolve methods relative to them.
