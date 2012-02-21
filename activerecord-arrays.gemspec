Gem::Specification.new do |s|
  s.name = 'activerecord-arrays'
  s.version = '0.1.2'

  s.summary = 'Arrays for ActiveRecord'
  s.description = 'Arrays for ActiveRecord'

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.5")
  s.authors = ['Roland Venesz']
  s.date = '2012-02-21'
  s.files = %w(README.md LICENSE) + Dir['lib/**/*.rb']
  s.require_paths = %w(lib)

  #s.add_dependency 'aws-s3'
end
