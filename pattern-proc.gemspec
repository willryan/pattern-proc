Gem::Specification.new do |s|
  s.name        = 'pattern-proc'
  s.version     = '0.0.3'
  s.date        = '2014-07-01'
  s.summary     = 'Pattern Proc'
  s.description = 'define a Proc with pattern matching "re-declaration" ala Haskell'
  s.authors     = ['William Pleasant-Ryan']
  s.email       = ['krelian18@gmail.com']
  s.files       = `git ls-files`.split("\n")
  s.files.delete(".gitignore")
  s.homepage    = "http://rubygems.org/gems/pattern-proc"
  s.license     = "MIT"
end

