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

    report.failed?.should_not eql(true)
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
    record3 = FormKeeper::Record.new(:email)
    record3.value = 'bar'
    record3.fail(:present)
    record3.fail(:length)

    report << record1
    report << record2
    report << record3

    report.failed?.should eql(true)
    report.failed_on?(:password).should eql(true)
    report.failed_on?(:password, :length).should eql(true)
    report.failed_on?(:password, :present).should_not eql(true)
    report.failed_on?(:email).should eql(true)
    report.failed_on?(:email, :present).should eql(true)
    report.failed_on?(:email, :length).should eql(true)
    report.failed_on?(:email, :ascii).should_not eql(true)
    report[:username].should == 'foo'
    report[:password].should be_nil
    report[:email].should be_nil

    report.failed_fields.should == [:password, :email]
    report.failed_constraints(:password).should == [:length]
    report.failed_constraints(:email).should == [:present, :length]

  end

  it "handles messages correctly" do

    messages = FormKeeper::Messages.from_file(File.dirname(__FILE__) + '/asset/messages.yaml')

    report = FormKeeper::Report.new(messages)
    record1 = FormKeeper::Record.new(:username)
    record1.value = 'foo'
    record2 = FormKeeper::Record.new(:password)
    record2.value = 'bar'
    record2.fail(:length)
    record3 = FormKeeper::Record.new(:email)
    record3.value = 'bar'
    record3.fail(:present)
    record3.fail(:length)

    report << record1
    report << record2
    report << record3

    report.messages(:login).should == ["Password's length should be between 8 and 16", "email is invalid."]
    report.messages(:login, :password).should == ["Password's length should be between 8 and 16"]
    report.message(:login, :password, :ascii).should be_nil
    report.message(:login, :password, :length).should == "Password's length should be between 8 and 16"
  end

  it "provides access to form inputs" do

    messages = FormKeeper::Messages.from_file(File.dirname(__FILE__) + '/asset/messages.yaml')

    report = FormKeeper::Report.new(messages)
    record1 = FormKeeper::Record.new(:name)
    record1.value = 'foo'
    record2 = FormKeeper::Record.new(:email)
    record2.value = 'bar'
    record3 = FormKeeper::Record.new(:contact)
    record3.value = 'baz'
    record2.fail(:email)

    report << record1
    report << record2
    report << record3

    report.value(:name).should eql('foo')
    report.value(:email).should eql('bar')
    report.value(:contact).should eql('baz')

    #expect {
    #  report.value(:blegga)
    #}.to raise_error(ArgumentError, "unknown field :blegga")
    report.value(:blegga).should be_nil
  end


end
