require 'support/test-data/pipeline/_ext/extensions'
require 'awestruct/extensions/pipeline'

Awestruct::Extensions::Pipeline.new do
  extension Awestruct::Test::Extensions::TestBeforeExtension.new
  extension Awestruct::Extensions::Indexifier.new
  after_extensions Awestruct::Test::Extensions::TestAfterExtension.new
  helper Awestruct::Extensions::Relative
  transformer Awestruct::Test::Extensions::LinkTransformer.new
  after_generation Awestruct::Test::Extensions::TestAfterGenerationExtension.new
end

