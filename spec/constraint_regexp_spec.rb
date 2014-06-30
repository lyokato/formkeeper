# -*- encoding: utf-8 -*-
require 'spec_helper'

describe FormKeeper::Constraint::Regexp do

  it "validate value correctly" do

    constraint = FormKeeper::Constraint::Regexp.new
    constraint.validate('this is ruby', %r{ruby}).should eql(true)
    constraint.validate('this is perl', %r{ruby}).should_not eql(true)

  end

end
