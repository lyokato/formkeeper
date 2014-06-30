# -*- encoding: utf-8 -*-
require 'spec_helper'

describe FormKeeper::CombinationConstraint::Time do

  it "validate value correctly" do

    constraint = FormKeeper::CombinationConstraint::Time.new
    constraint.validate(['23', '2', '12'], true).should eql(true)
    constraint.validate(['23', '2', '12', '11'], true).should_not eql(true)
    constraint.validate(['23', '2', 'aa'], true).should_not eql(true)
    constraint.validate(['0', '2', '12'], true).should eql(true)
    constraint.validate(['-2', '2', '12'], true).should_not eql(true)
    constraint.validate(['2', '60', '12'], true).should_not eql(true)
    constraint.validate(['2', '2', '60'], true).should_not eql(true)

  end

end
