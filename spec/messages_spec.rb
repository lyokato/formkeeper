require 'spec_helper'

describe FormKeeper::Messages do

  it "handles messages file correctly" do

    messages = FormKeeper::Messages.from_file(File.dirname(__FILE__) + '/asset/messages.yaml')

    messages.get('login', 'username', 'present').should == "You must input name"

    # work with symbols
    messages.get(:login, :username, :present).should == "You must input name"

    # unknown field - use DEFAULT action block
    messages.get(:login, :username, :unknown).should == "Input your name correctly!"

    # unknown field and DEFAULT action block not found
    messages.get(:login, :password, :unknown).should == "password is invalid."

    # unknown action - search from DEFAULT action block
    messages.get(:unknown, :username, :present).should == "Input your name correctly!"
  end

end
