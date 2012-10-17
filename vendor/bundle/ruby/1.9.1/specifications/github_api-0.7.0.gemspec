# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "github_api"
  s.version = "0.7.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Piotr Murach"]
  s.date = "2012-09-09"
  s.description = " Ruby wrapper that supports all of the GitHub API v3 methods(nearly 200). It's build in a modular way, that is, you can either instantiate the whole api wrapper Github.new or use parts of it e.i. Github::Repos.new if working solely with repositories is your main concern. "
  s.email = ""
  s.homepage = "https://github.com/peter-murach/github"
  s.post_install_message = "\n--------------------------------------------------------------------------------\nThank you for installing github_api-0.7.0.\n\n*NOTE*: Version 0.5.0 introduces breaking changes to the way github api is queried.\nThe interface has been rewritten to be more consistent with REST verbs that\ninteract with GitHub hypermedia resources. Thus, to list resources 'list' or 'all'\nverbs are used, to retrieve individual resource 'get' or 'find' verbs are used.\nOther CRUDE operations on all resources use preditable verbs as well, such as\n'create', 'delete' etc...\n\nAgain sorry for the inconvenience but I trust that this will help in easier access to\nthe GitHub API and library .\n\nFor more information: http://rubydoc.info/github/peter-murach/github/master/frames\n\n--------------------------------------------------------------------------------\n  "
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "Ruby wrapper for the GitHub API v3"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hashie>, ["~> 1.2.0"])
      s.add_runtime_dependency(%q<faraday>, ["~> 0.8.1"])
      s.add_runtime_dependency(%q<multi_json>, ["~> 1.3"])
      s.add_runtime_dependency(%q<oauth2>, [">= 0"])
      s.add_runtime_dependency(%q<nokogiri>, ["~> 1.5.2"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<cucumber>, [">= 0"])
      s.add_development_dependency(%q<webmock>, ["~> 1.8.0"])
      s.add_development_dependency(%q<vcr>, ["~> 2.2.0"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.6.1"])
      s.add_development_dependency(%q<guard>, [">= 0"])
      s.add_development_dependency(%q<guard-rspec>, [">= 0"])
      s.add_development_dependency(%q<guard-cucumber>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
    else
      s.add_dependency(%q<hashie>, ["~> 1.2.0"])
      s.add_dependency(%q<faraday>, ["~> 0.8.1"])
      s.add_dependency(%q<multi_json>, ["~> 1.3"])
      s.add_dependency(%q<oauth2>, [">= 0"])
      s.add_dependency(%q<nokogiri>, ["~> 1.5.2"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<cucumber>, [">= 0"])
      s.add_dependency(%q<webmock>, ["~> 1.8.0"])
      s.add_dependency(%q<vcr>, ["~> 2.2.0"])
      s.add_dependency(%q<simplecov>, ["~> 0.6.1"])
      s.add_dependency(%q<guard>, [">= 0"])
      s.add_dependency(%q<guard-rspec>, [">= 0"])
      s.add_dependency(%q<guard-cucumber>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
    end
  else
    s.add_dependency(%q<hashie>, ["~> 1.2.0"])
    s.add_dependency(%q<faraday>, ["~> 0.8.1"])
    s.add_dependency(%q<multi_json>, ["~> 1.3"])
    s.add_dependency(%q<oauth2>, [">= 0"])
    s.add_dependency(%q<nokogiri>, ["~> 1.5.2"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<cucumber>, [">= 0"])
    s.add_dependency(%q<webmock>, ["~> 1.8.0"])
    s.add_dependency(%q<vcr>, ["~> 2.2.0"])
    s.add_dependency(%q<simplecov>, ["~> 0.6.1"])
    s.add_dependency(%q<guard>, [">= 0"])
    s.add_dependency(%q<guard-rspec>, [">= 0"])
    s.add_dependency(%q<guard-cucumber>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
  end
end
