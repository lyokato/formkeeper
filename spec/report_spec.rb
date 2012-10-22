require 'spec_helper'

describe FormKeeper::Report do

  it "handles valid records correctly" do

    report = FormKeeper::Report.new
    record1 = FormKeeper::Record.new(:username)
    record1.value = 'foo'
    record2 = FormKeeper::Record.new(:password)
    record2.value = 'bar'

    report << record1
    report << record2

    report.failed?.should_not be_true
    report[:username].should == 'foo'
    report[:password].should == 'bar'

  end

  it "handles invalid records correctly" do

    report = FormKeeper::Report.new
    record1 = FormKeeper::Record.new(:username)
    record1.value = 'foo'
    record2 = FormKeeper::Record.new(:password)
    record2.value = 'bar'
    record2.fail(:length)

    report << record1
    report << record2

    report.failed?.should be_true
    report.failed_on?(:password).should be_true
    report[:username].should == 'foo'
    report[:password].should be_nil

  end

end
