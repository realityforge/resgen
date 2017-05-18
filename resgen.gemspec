# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name               = %q{resgen}
  s.version            = '1.0.0'
  s.platform           = Gem::Platform::RUBY

  s.authors            = ['Peter Donald']
  s.email              = %q{peter@realityforge.org}

  s.homepage           = %q{https://github.com/realityforge/resgen}
  s.summary            = %q{A tool to generate resource descriptors from resource assets.}
  s.description        = %q{A tool to generate resource descriptors from resource assets.}

  s.rubyforge_project  = %q{resgen}

  s.files              = `git ls-files`.split("\n")
  s.test_files         = `git ls-files -- {spec}/*`.split("\n")
  s.executables        = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.default_executable = []
  s.require_paths      = %w(lib)

  s.has_rdoc           = false
  s.rdoc_options       = %w(--line-numbers --inline-source --title resgen)

  s.add_dependency 'reality-mda', '>= 1.5.0'
  s.add_dependency 'reality-core', '>= 1.6.0'
  s.add_dependency 'reality-facets', '>= 1.8.0'
  s.add_dependency 'reality-generators', '>= 1.11.0'
  s.add_dependency 'reality-naming', '>= 1.9.0'
  s.add_dependency 'reality-model', '>= 1.1.0'
  s.add_dependency 'reality-orderedhash', '>= 1.0.0'
  s.add_dependency 'sass', '>= 3.4.22'
  s.add_dependency 'nokogiri', '>= 1.6.8.1'

  s.add_development_dependency(%q<minitest>, ['= 5.9.1'])
  s.add_development_dependency(%q<test-unit>, ['= 3.1.5'])
end
