require 'spec_helper'
require 'awestruct/scm/git'

describe Awestruct::Scm::Git do
  specify 'should respond_to :uncommitted_changes?' do
    expect(subject).to respond_to :uncommitted_changes?
  end
  context "#uncommitted_changes?('.')" do
    specify 'when there are no changes, returns false' do
      Open3.should_receive(:popen3).with('git status --porcelain', :chdir => '.').and_yield(nil, StringIO.new(''), StringIO.new(''), nil)
      expect(subject.uncommitted_changes? '.').to be_false
    end

    specify 'when there are changes to untracked files, returns true' do
      Open3.should_receive(:popen3).with('git status --porcelain', :chdir => '.').and_yield(nil, StringIO.new('?? test.rb'), StringIO.new(''), nil)
      expect(subject.uncommitted_changes? '.').to be_true
    end

    specify 'when there are modifications, returns true' do
      Open3.should_receive(:popen3).with('git status --porcelain', :chdir => '.').and_yield(nil, StringIO.new(' M test.rb'), StringIO.new(''), nil)
      expect(subject.uncommitted_changes? '.').to be_true
    end

    specify 'when there are additions and modifications, returns true' do
      Open3.should_receive(:popen3).with('git status --porcelain', :chdir => '.').and_yield(nil, StringIO.new('AM test.rb'), StringIO.new(''), nil)
      expect(subject.uncommitted_changes? '.').to be_true
    end
  end
end