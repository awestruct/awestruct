require 'awestruct/cli/console'
require 'awestruct/astruct'
require 'spec_helper'
require 'stringio'

describe Awestruct::CLI::Console do


  # query format: pageexp[:field][:depoperator]
  # blogs:title:<  <-- show all dependents on title for pages that match blogs*
  # blogs:title:>  <-- show all dependents on title for pages that match blogs*

  before :all do

    pages = []
    pages << Awestruct::AStruct.new({"output_path" => "/blog/page1.html", "title" => "Page 1 Blog"})
    pages << Awestruct::AStruct.new({"output_path" => "/blog/page2.html", "title" => "Page 2 Blog"})
    pages << Awestruct::AStruct.new({"output_path" => "/blog/page3.html", "title" => "Page 3 Blog"})
    pages << Awestruct::AStruct.new({"output_path" => "/blog/page4.html", "author" => "Page 4 Author"})

    pages[0].dependencies = Awestruct::AStruct.new({"dependents" => [] , "dependencies" => [] << pages[1]})
    pages[1].dependencies = Awestruct::AStruct.new({"dependents" => [] << pages[0], "dependencies" => []})
    pages[2].dependencies = Awestruct::AStruct.new({"dependents" => [], "dependencies" => []})

    @console = TestConsole.new pages
  end

  it "should find all pages" do
    output = StringIO.new
    @console.execute("page1", output)

    output.seek(0)
    result = output.read
    result.should =~ %r(/blog/page1.html)
  end

  it "should find all variables" do
    output = StringIO.new
    @console.execute(":titl", output)

    output.seek(0)
    result = output.read
    result.should =~ %r(/blog/page1.html)
    result.should =~ %r(title -> "Page 1 Blog")
    result.should =~ %r(/blog/page2.html)
    result.should =~ %r(title -> "Page 2 Blog")
    result.should =~ %r(/blog/page3.html)
    result.should =~ %r(title -> "Page 3 Blog")
  end

  it "should find all pages and variables" do
    output = StringIO.new
    @console.execute("page1:tit", output)

    output.seek(0)
    result = output.read
    result.should =~ %r(/blog/page1.html)
    result.should =~ %r(title -> "Page 1 Blog")
  end

  it "should find all pages dependencies" do
    output = StringIO.new
    @console.execute("page1:>", output)

    output.seek(0)
    result = output.read
    result.should =~ %r(/blog/page1.html)
    result.should =~ %r(> /blog/page2.html)
  end

  it "should find all pages dependents" do
    output = StringIO.new
    @console.execute("page2:<", output)

    output.seek(0)
    result = output.read
    result.should =~ %r(/blog/page2.html)
    result.should =~ %r(< /blog/page1.html)
  end

  it "should find all pages variable dependencies < makes sense?"

  it "should find all pages variable dependents < makes sense?"

end

class TestConsole < Awestruct::CLI::Console

  def initialize(pages)
    @pages = pages
  end

  def get_pages
    @pages
  end
end