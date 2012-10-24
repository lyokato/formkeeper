require 'spec_helper'

describe FormKeeper::Filter::Strip do

  it "filters value correctly" do
    filter = FormKeeper::Filter::Strip.new
    filter.process("foo").should == "foo";
    filter.process(" foo").should == "foo";
    filter.process("foo ").should == "foo";
    filter.process(" foo ").should == "foo";
    filter.process("   foo ").should == "foo";
  end

end
