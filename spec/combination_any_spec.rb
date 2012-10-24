# -*- encoding: utf-8 -*-
require 'spec_helper'

describe FormKeeper::CombinationConstraint::Any do

  it "validate value correctly" do

    constraint = FormKeeper::CombinationConstraint::Any.new
    constraint.validate(['aaaa', 'bbbb'], true).should be_true
    constraint.validate(['', ''], true).should_not be_true
    constraint.validate(['', nil], true).should_not be_true
    constraint.validate(['aaa', nil], true).should be_true
    constraint.validate(['aaa', 'bbbb', 'cccc', nil], true).should be_true

  end

end
