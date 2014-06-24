# -*- encoding: utf-8 -*-
require 'spec_helper'

describe FormKeeper::Constraint::Ascii do

  it "validate value correctly" do

    constraint = FormKeeper::Constraint::Ascii.new
    constraint.validate('aaaa', true).should eql(true)
    constraint.validate('a%[]Aaa', false).should_not eql(true)
    constraint.validate('[aAaa.', true).should eql(true)
    constraint.validate('[a Aaa.', true).should_not eql(true)

  end

end
