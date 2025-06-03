# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'equation_master_gem/version'

Gem::Specification.new do |spec|
  spec.name          = "equation_master"
  spec.version       = EquationMaster::VERSION
  spec.authors       = ["KanroL", "Fayld", "Marty_s64"]
  spec.email         = ["martisagak@gmail.com","kraoleg@SFEDU.ru", "volkovmen2004@yandex.ru","aleks3204932@MAIL.RU"]

  spec.summary       = "Gem for solving quadratic and cubic equations"
  spec.description   = "A library for solving equations and plotting graphs in terminal"
  spec.homepage      = "https://github.com/martysama64/Equation-master/blob/main/"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
end