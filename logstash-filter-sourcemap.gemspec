Gem::Specification.new do |s|
  s.name = 'logstash-filter-sourcemap'
  s.version = '0.1.dev'
  s.licenses = ['Apache License (2.0)']
  s.summary = 'This filter converts links in JavaScript stacktraces based on external sourcemaps.'
  s.description = 'This gem is a Logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/plugin install gemname. This gem is not a stand-alone program'
  s.authors = ['Michael Kuzmin']
  s.email = 'mkuzmin@gmail.com'
  s.homepage = 'https://github.com/mkuzmin/logstash-filter-sourcemap'
  s.require_paths = ['lib']

  # Files
  s.files = Dir['lib/**/*', 'spec/**/*', 'vendor/**/*', '*.gemspec', '*.md', 'CONTRIBUTORS', 'Gemfile', 'LICENSE', 'NOTICE.TXT']
  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = {'logstash_plugin' => 'true', 'logstash_group' => 'filter'}

  # Gem dependencies
  s.add_runtime_dependency 'logstash-core', '>= 2.0.0', '< 3.0.0'
  s.add_runtime_dependency 'sourcemap'
  s.add_development_dependency 'logstash-devutils'
end
