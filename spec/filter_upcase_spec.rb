require 'spec_helper'

describe FormKeeper::Filter::UpCase do

  it "filters value correctly" do
    filter = FormKeeper::Filter::UpCase.new
    filter.process("FOO").should == "FOO";
    filter.process("fOO").should == "FOO";
    filter.process("foo").should == "FOO";
    filter.process(" foo").should == " FOO";
  end

end
