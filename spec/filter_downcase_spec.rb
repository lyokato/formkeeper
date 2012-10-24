require 'spec_helper'

describe FormKeeper::Filter::DownCase do

  it "filters value correctly" do
    filter = FormKeeper::Filter::DownCase.new
    filter.process("foo").should == "foo";
    filter.process("Foo").should == "foo";
    filter.process("FOO").should == "foo";
    filter.process(" FOO").should == " foo";
  end

end
