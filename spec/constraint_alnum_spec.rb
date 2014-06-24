# -*- encoding: utf-8 -*-
require 'spec_helper'

describe FormKeeper::Constraint::Alnum do

  it "validate value correctly" do

    constraint = FormKeeper::Constraint::Alnum.new
    constraint.validate('abcd', true).should eql(true)
    constraint.validate('a1234bcd', true).should eql(true)
    constraint.validate('a%[]Aaa', true).should_not eql(true)
    constraint.validate('ab cd', true).should_not eql(true)

  end

end
