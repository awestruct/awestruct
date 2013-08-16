
require 'awestruct/cli/deploy'

describe Awestruct::CLI::Deploy do

  it "should use a given deploy[:type]" do
    deployer = Awestruct::CLI::Deploy.new({}, {'type' => :foo})
    deployer.deploy_type.should == :foo
  end

  it "should use rsync if no deploy[:type] is given" do
    deployer = Awestruct::CLI::Deploy.new({}, {})
    deployer.deploy_type.should == :rsync
  end

  it "should use github_pages if deploy['host'] is github_pages and no deploy[:type] is given" do
    deployer = Awestruct::CLI::Deploy.new({}, {'host' => :github_pages})
    deployer.deploy_type.should == :github_pages
  end

  it "should use a given deploy['type'] even if deploy['host'] is github_pages" do
    deployer = Awestruct::CLI::Deploy.new({}, {'type' => :foo, 'host'=>:github_pages})
    deployer.deploy_type.should == :foo
  end

  it "should use s3 if deploy['type'] is s3" do
    deployer = Awestruct::CLI::Deploy.new({}, {'type' => :s3})
    deployer.deploy_type.should == :s3
  end

  it "should work with strings for keys" do
    deployer = Awestruct::CLI::Deploy.new({}, {'host' => :github_pages})
    deployer.deploy_type.should == :github_pages
  end

  it "should work with strings for values" do
    deployer = Awestruct::CLI::Deploy.new({}, {'host' => 'github_pages'})
    deployer.deploy_type.should == :github_pages
  end

  it "should gzip if deploy['gzip'] is true" do
    site_config = mock
    site_config.stub(:output_dir).and_return '_site'

    deploy_config = mock
    deploy_config.stub(:[]).with('gzip').and_return true
    deploy_config.stub(:[]).with('uncommitted').and_return true

    deployer = Awestruct::Deploy::Base.new(site_config, deploy_config)
    deployer.should_receive(:gzip_site)
    deployer.run(deploy_config)
  end

  it "should only gzip html, css and js files" do
    site_tmp_dir = Dir.mktmpdir("site_dir")
    site_src_dir = File.join(File.dirname(__FILE__), 'test-data/gzip')
    FileUtils.cp_r(site_src_dir, site_tmp_dir)
    site_dir = "#{site_tmp_dir}/gzip"

    site_config = mock
    site_config.stub(:output_dir).and_return "#{site_dir}"

    deploy_config = mock
    deploy_config.stub(:[]).with('gzip').and_return true

    deployer = Awestruct::Deploy::Base.new(site_config, deploy_config)
    deployer.should_receive(:gzip_file).with("#{site_dir}/yes.html")
    deployer.should_receive(:gzip_file).with("#{site_dir}/yes.js")
    deployer.should_receive(:gzip_file).with("#{site_dir}/subdir/yes.css")
    deployer.should_not_receive(:gzip_file).with("#{site_dir}/no.txt")
    deployer.should_not_receive(:gzip_file).with("#{site_dir}/no.html.gz")
    deployer.gzip_site(site_dir)
  end

  it "should gzip only once" do
    site_tmp_dir = Dir.mktmpdir("site_dir")
    site_src_dir = File.join(File.dirname(__FILE__), 'test-data/gzip')
    FileUtils.cp_r(site_src_dir, site_tmp_dir)
    site_dir = "#{site_tmp_dir}/gzip"

    site_config = mock
    site_config.stub(:output_dir).and_return "#{site_dir}"

    deploy_config = mock
    deploy_config.stub(:[]).with('gzip').and_return true

    deployer = Awestruct::Deploy::Base.new(site_config, deploy_config)
    deployer.gzip_site(site_dir)

    # Gzip only once
    deployer.should_not_receive(:gzip_file).with("#{site_dir}/yes.html")
    deployer.should_not_receive(:gzip_file).with("#{site_dir}/yes.js")
    deployer.should_not_receive(:gzip_file).with("#{site_dir}/subdir/yes.css")
    deployer.should_not_receive(:gzip_file).with("#{site_dir}/no.txt")
    deployer.gzip_site(site_dir)
  end

end
