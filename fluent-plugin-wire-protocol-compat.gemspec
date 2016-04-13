# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-wire-protocol-compat"
  spec.version       = File.read("VERSION").strip
  spec.authors       = ["Tomás Rojas"]
  spec.email         = ["tmsrjs@gmail.com"]

  spec.summary       = %q{Adds in_forward wire protocol support to in_udp, in_tcp and in_tail}
  spec.homepage      = "https://github.com/bitex-la/fluent-plugin-wire-protocol-compat"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "fluentd", ">= 0.10.51"

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "timecop"
end
