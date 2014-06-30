# -*- encoding: utf-8 -*-
require 'spec_helper'

describe FormKeeper::CombinationConstraint::DateTime do

  it "validate value correctly" do

    constraint = FormKeeper::CombinationConstraint::DateTime.new
    constraint.validate(['2012', '2', '2', '23', '2', '12'], true).should eql(true)
    constraint.validate(['2012', '2', '2', '23', '2', '12', '11'], true).should_not eql(true)
    constraint.validate(['2012', '2', '2', '23', '2', 'a',], true).should_not eql(true)
    constraint.validate(['2012', '13', '2', '23', '2', '12',], true).should_not eql(true)
    constraint.validate(['2012', '2', '50', '23', '2', '12',], true).should_not eql(true)
    constraint.validate(['2012', '2', '28', '25', '2', '12',], true).should_not eql(true)
    constraint.validate(['2012', '2', '28', '23', '60', '12',], true).should_not eql(true)
    constraint.validate(['2012', '2', '28', '23', '59', '60',], true).should_not eql(true)

  end

end
