# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "infusible"
  spec.version = "1.0.0"
  spec.authors = ["Brooke Kuhlmann"]
  spec.email = ["brooke@alchemists.io"]
  spec.homepage = "https://www.alchemists.io/projects/infusible"
  spec.summary = "Automates the injection of dependencies into your class."
  spec.license = "Hippocratic-2.1"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/bkuhlmann/infusible/issues",
    "changelog_uri" => "https://www.alchemists.io/projects/infusible/versions",
    "documentation_uri" => "https://www.alchemists.io/projects/infusible",
    "funding_uri" => "https://github.com/sponsors/bkuhlmann",
    "label" => "Infusible",
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/bkuhlmann/infusible"
  }

  spec.signing_key = Gem.default_key_path
  spec.cert_chain = [Gem.default_cert_path]

  spec.required_ruby_version = "~> 3.2"
  spec.add_dependency "marameters", "~> 1.0"
  spec.add_dependency "zeitwerk", "~> 2.6"

  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.files = Dir["*.gemspec", "lib/**/*"]
end
