require 'awestruct/engine'
require 'awestruct/config'
require 'rspec'

require 'hashery'

REQUIRED_VARIABLES = [:page, :simple_name, :syntax, :extension]
ALL_VARIABLES = REQUIRED_VARIABLES + [:format, :matcher, :unless, :site_overrides]

shared_examples 'a handler' do |theories|

  def handler_file(path)
    "#{@site.config.dir}/#{path}"
  end

  def create_context
    Hashery::OpenCascade[{ :site => @site }]
  end

  describe Awestruct::Handlers do

    before :each do
      @engine = init
      @site = @engine.site
    end

    def init
      opts = Awestruct::CLI::Options.new
      opts.source_dir = test_data_dir 'handlers' 
      config = Awestruct::Config.new( opts )

      engine = Awestruct::Engine.new( config )
      engine.load_default_site_yaml
      engine
    end

    def create_handler(page)
      @engine.load_page File.join(@engine.config.dir, page)
    end

    def merge_site_overrides(overrides)
      @site.update overrides
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

      it "should provide simple name '#{theory[:simple_name]}' for page '#{theory[:page]}'" do
        handler = create_handler theory[:page]
        handler.simple_name.should == theory[:simple_name]
      end

      it "should provide content syntax '#{theory[:syntax]}' for page '#{theory[:page]}'" do
        handler = create_handler theory[:page]
        handler.content_syntax.should == theory[:syntax]
      end

      it "should provide output extension '#{theory[:extension]}' for page '#{theory[:page]}'" do
        handler = create_handler theory[:page]
        handler.output_extension.should == theory[:extension]
      end

      unless theory[:format].nil?
        it "should set the engine format '#{theory[:format]}' for page '#{theory[:page]}'" do
          page = create_handler theory[:page]
          handler = page.handler
          begin
            handler = handler.delegate
          end while handler.delegate and !handler.kind_of?(Awestruct::Handlers::TiltHandler)
          handler.should_not be_nil
          handler.options[:format].should == theory[:format]
        end
      end

      unless theory[:matcher].nil?

        it "should render page '#{theory[:page]}'" do
          if theory[:unless].nil? or !theory[:unless][:exp].call()
            if theory.has_key? :site_overrides
              merge_site_overrides(theory[:site_overrides])
            end
            handler = create_handler theory[:page]
            handler.update(additional_config_page) { |k, oldval, newval| oldval } if respond_to?('additional_config_page')
            output = handler.rendered_content(handler.create_context)
            output.should_not be_nil

            theory[:matcher].call(output, handler) if theory[:matcher].arity == 2
            theory[:matcher].call(output) if theory[:matcher].arity == 1
          else
            pending theory[:unless][:message]
          end
        end

      end

    end
  end
end
