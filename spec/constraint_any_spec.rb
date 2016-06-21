# -*- encoding: utf-8 -*-
require 'spec_helper'

describe FormKeeper::Constraint::Any do

  it "validate value correctly" do

    constraint = FormKeeper::Constraint::Any.new
    constraint.validate('male', ['male', 'female']).should eql(true)
    constraint.validate('foobar', ['male', 'female']).should eql(false)

  end

end
