# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "bard-rake"
  s.version = "0.10.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Micah Geisel"]
  s.date = "2013-05-19"
  s.description = "Rake tasks for all bard projects.\n* Bootstrap projects\n* Database backup"
  s.email = "micah@botandrose.com"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bard-rake.gemspec",
    "lib/bard-rake.rb",
    "lib/bard/rake.rb",
    "lib/bard/rake/bootstrap.rb",
    "lib/bard/rake/db_dump_load.rb",
    "lib/bard/rake/db_migrate_sanity.rb",
    "lib/bard/rake/railtie.rb",
    "lib/bard/rake/testing.rb",
    "spec/bard-rake_spec.rb",
    "spec/spec.opts",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/botandrose/bard-rake"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "Rake tasks for all bard projects."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
  end
end

