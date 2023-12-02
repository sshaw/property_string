# frozen_string_literal: true

require_relative "lib/property_string"

Gem::Specification.new do |spec|
  spec.name = "property_string"
  spec.version = PropertyString::VERSION
  spec.authors = ["sshaw"]
  spec.email = ["skye.shaw@gmail.com"]

  spec.summary = "Use Java-style property notation to execute method call chains on an object."
  spec.homepage = "https://github.com/sshaw/property_string"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
