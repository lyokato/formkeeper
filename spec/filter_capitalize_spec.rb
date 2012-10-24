require 'spec_helper'

describe FormKeeper::Filter::Capitalize do

  it "filters value correctly" do
    filter = FormKeeper::Filter::Capitalize.new
    filter.process("FOO").should == "Foo";
    filter.process("fOO").should == "Foo";
    filter.process("foo").should == "Foo";
    filter.process(" foo").should == " foo";
  end

end
