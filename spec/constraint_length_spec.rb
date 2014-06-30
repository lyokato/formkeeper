# -*- encoding: utf-8 -*-
require 'spec_helper'

describe FormKeeper::Constraint::Length do

  it "validate value correctly" do

    constraint = FormKeeper::Constraint::Length.new
    constraint.validate('aaaa', 0..10).should eql(true)
    constraint.validate('aaaa', 0..3).should_not eql(true)
    constraint.validate('aaaa', 4).should eql(true)
    constraint.validate('aaaa', 3).should_not eql(true)

    constraint.validate('ほげ', 2).should eql(true)

  end

end
