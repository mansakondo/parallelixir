# frozen_string_literal: true

require_relative "lib/parallelixir/version"

Gem::Specification.new do |spec|
  spec.name          = "parallelixir"
  spec.version       = Parallelixir::VERSION
  spec.authors       = ["mansakondo"]
  spec.email         = ["mansakondo22@gmail.com"]

  spec.summary       = "A library which delegates Ruby background job processing to Elixir"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.homepage      = "https://github.com/mansakondo/parallelixir"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "redis"
  spec.add_dependency "connection_pool"
  spec.add_dependency "erlectricity"
  spec.add_dependency "activesupport"
  spec.add_dependency "rake"
end
