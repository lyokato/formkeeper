require 'spec_helper'

describe FormKeeper::Record do

  it "handles failure correctly" do
    record = FormKeeper::Record.new(:username)

    record.name.should == :username

    record.value.should be_nil
    record.value = 'foo'
    record.value.should == 'foo'

    record.failed?.should_not eql(true)

    record.fail(:present)
    record.fail(:length)

    record.failed?.should eql(true)
    record.failed_by?(:present).should eql(true)
    record.failed_by?(:length).should eql(true)
    record.failed_by?(:bytesize).should_not eql(true)

    record.failed_constraints[0].should == :present
    record.failed_constraints[1].should == :length
  end

end
