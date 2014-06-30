# -*- encoding: utf-8 -*-
require 'spec_helper'

describe FormKeeper::Constraint::Int do

  it "validate value correctly" do

    constraint = FormKeeper::Constraint::Int.new
    constraint.validate('aaaa', true).should_not eql(true)
    constraint.validate('aaaa', false).should eql(true)
    constraint.validate('1111', true).should eql(true)
    constraint.validate('1111', false).should_not eql(true)
    constraint.validate('-1111', true).should eql(true)
    constraint.validate('-1111', false).should_not eql(true)

    constraint.validate('1111', {:gt => 111}).should eql(true)
    constraint.validate('1111', {:gt => 2222}).should_not eql(true)
    constraint.validate('1111', {:gt => 111, :lte => 1111}).should eql(true)
    constraint.validate('1111', {:gt => 111, :lt => 1111}).should_not eql(true)
    constraint.validate('1111', {:gt => 111, :lt => 1112}).should eql(true)
    constraint.validate('1111', {:gte => 1111, :lte => 1111}).should eql(true)
    constraint.validate('1111', {:between => 1110..1112}).should eql(true)
    constraint.validate('1111', {:between => 1113..1115}).should_not eql(true)
  end

end
