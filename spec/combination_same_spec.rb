# -*- encoding: utf-8 -*-
require 'spec_helper'

describe FormKeeper::CombinationConstraint::Same do

  it "validate value correctly" do

    constraint = FormKeeper::CombinationConstraint::Same.new
    constraint.validate('aaaa', true).should_not eql(true)
    constraint.validate(['aaaa', 'bbbb'], true).should_not eql(true)
    constraint.validate(['aaaa', 'aaaa', 'aaaa'], true).should_not eql(true)
    constraint.validate(['aaaa', 'aaaa'], true).should eql(true)

  end

end
