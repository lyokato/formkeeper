# -*- encoding: utf-8 -*-
require 'spec_helper'

describe FormKeeper::CombinationConstraint::Any do

  it "validates values correctly" do

    constraint = FormKeeper::CombinationConstraint::Any.new
    constraint.validate(['aaaa', 'bbbb'], true).should eql(true)
    constraint.validate(['', ''], true).should_not eql(true)
    constraint.validate(['', nil], true).should_not eql(true)
    constraint.validate(['aaa', nil], true).should eql(true)
    constraint.validate(['aaa', 'bbbb', 'cccc', nil], true).should eql(true)

  end

end
