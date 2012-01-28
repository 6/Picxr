require 'open-uri'
# Source: http://stackoverflow.com/questions/694115/why-does-ruby-open-uris-open-return-a-stringio-in-my-unit-test-but-a-fileio-in
# Don't allow downloaded files to be created as StringIO. Force a tempfile to be created.
if OpenURI::Buffer.const_defined?('StringMax')
  OpenURI::Buffer.send :remove_const, 'StringMax'
end
OpenURI::Buffer.const_set 'StringMax', 0
