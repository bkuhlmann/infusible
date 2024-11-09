# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "infusible"
  spec.version = "3.11.0"
  spec.authors = ["Brooke Kuhlmann"]
  spec.email = ["brooke@alchemists.io"]
  spec.homepage = "https://alchemists.io/projects/infusible"
  spec.summary = "An automatic dependency injector."
  spec.license = "Hippocratic-2.1"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/bkuhlmann/infusible/issues",
    "changelog_uri" => "https://alchemists.io/projects/infusible/versions",
    "homepage_uri" => "https://alchemists.io/projects/infusible",
    "funding_uri" => "https://github.com/sponsors/bkuhlmann",
    "label" => "Infusible",
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/bkuhlmann/infusible"
  }

  spec.signing_key = Gem.default_key_path
  spec.cert_chain = [Gem.default_cert_path]

  spec.required_ruby_version = ">= 3.3", "<= 3.4"
  spec.add_dependency "marameters", "~> 3.12"

  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.files = Dir["*.gemspec", "lib/**/*"]
end
