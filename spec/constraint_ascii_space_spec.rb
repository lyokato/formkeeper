# -*- encoding: utf-8 -*-
require 'spec_helper'

describe FormKeeper::Constraint::AsciiSpace do

  it "validate value correctly" do

    constraint = FormKeeper::Constraint::AsciiSpace.new
    constraint.validate('aaaa', true).should eql(true)
    constraint.validate('a%[]Aaa', false).should_not eql(true)
    constraint.validate('[aAaa.', true).should eql(true)
    constraint.validate('[a Aaa.', true).should eql(true)

  end

end
