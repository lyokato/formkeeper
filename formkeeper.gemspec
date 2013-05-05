# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'formkeeper/version'

Gem::Specification.new do |gem|
  gem.name          = "formkeeper"
  gem.version       = FormKeeper::VERSION
  gem.authors       = ["lyokato"]
  gem.email         = ["lyo.kato@gmail.com"]
  gem.description   = %q{Helper library for stuff around HTML forms}
  gem.summary       = %q{This modules provides you an easy way for form-validation and fill-in-form}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "hpricot"
  gem.add_dependency "rack"

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rake"
end
