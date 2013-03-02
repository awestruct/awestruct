require 'awestruct/engine'
require 'awestruct/config'
require 'rspec'

require 'hashery/open_cascade'

REQUIRED_VARIABLES = [:page, :simple_name, :syntax, :extension]
ALL_VARIABLES = REQUIRED_VARIABLES + [:matcher, :unless]

shared_examples "a handler" do |theories|

  def handler_file(path)
    "#{@site.config.dir}/#{path}"
  end

  def create_context
    OpenCascade.new :site=>@site
  end

  describe Awestruct::Handlers do

    before :all do

      @engine = Awestruct::Engine.new(
                    Awestruct::Config.new( File.expand_path(File.dirname(__FILE__) + '/../') + '/test-data/handlers' ))
      @engine.load_default_site_yaml
      @site = @engine.site

      @site.merge! additional_config if respond_to?("additional_config")
    end

    def create_handler(page)
      @engine.load_page File.join(@engine.config.dir, page)
    end

    theories.each do |theory|

      # Validate input
      missing = []
      REQUIRED_VARIABLES.each do |key|
        missing << key unless theory.has_key? key
      end
      raise "Missing required variable(s) '#{missing.join(', ')}'. Requires all '#{REQUIRED_VARIABLES.join(', ')}'" if missing.size > 0

      unknown = theory.keys-ALL_VARIABLES
      raise "Unknown theory variable(s) '#{unknown.join(', ')}'. Supported variables '#{ALL_VARIABLES.join(', ')}'" if unknown.size > 0

      # Prove the theory

      it "should provide simple name '#{theory[:simple_name]}'' for page '#{theory[:page]}'" do
        handler = create_handler theory[:page]
        handler.simple_name.should == theory[:simple_name]
      end

      it "should provide content syntax '#{theory[:syntax]}'' for page '#{theory[:page]}'" do
        handler = create_handler theory[:page]
        handler.content_syntax.should == theory[:syntax]
      end

      it "should provide output extension '#{theory[:extension]}'' for page '#{theory[:page]}'" do
        handler = create_handler theory[:page]
        handler.output_extension.should == theory[:extension]
      end

      if !theory[:matcher].nil?

        it "should render page '#{theory[:page]}'" do
          if theory[:unless].nil? or !theory[:unless][:exp].call()
            handler = create_handler theory[:page]
            output = handler.rendered_content( create_context )
            output.should_not be_nil

            theory[:matcher].call(output)
          else
            pending theory[:unless][:message]
          end
        end

      end

    end
  end
end
