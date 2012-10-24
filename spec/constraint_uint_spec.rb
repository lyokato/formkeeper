# -*- encoding: utf-8 -*-
require 'spec_helper'

describe FormKeeper::Constraint::Uint do

  it "validate value correctly" do

    constraint = FormKeeper::Constraint::Uint.new
    constraint.validate('aaaa', true).should_not be_true
    constraint.validate('aaaa', false).should be_true
    constraint.validate('1111', true).should be_true
    constraint.validate('1111', false).should_not be_true
    constraint.validate('-1111', true).should_not be_true
    constraint.validate('-1111', false).should be_true

  end

end
