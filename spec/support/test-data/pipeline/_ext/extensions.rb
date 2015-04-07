module Awestruct
  module Test
    module Extensions
      class TestBeforeExtension
        def execute site
        end
      end

      class TestAfterExtension
        def execute site
        end
      end

      class TestAfterGenerationExtension
        def execute site
        end
      end

      class LinkTransformer
        def transform site, page, content
        end
      end
    end
  end
end

