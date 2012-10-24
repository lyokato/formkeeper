# -*- encoding: utf-8 -*-
require 'spec_helper'

describe FormKeeper::Constraint::Ascii do

  it "validate value correctly" do

    constraint = FormKeeper::Constraint::Ascii.new
    constraint.validate('aaaa', true).should be_true
    constraint.validate('a%[]Aaa', false).should_not be_true
    constraint.validate('[aAaa.', true).should be_true
    constraint.validate('[a Aaa.', true).should_not be_true

  end

end
