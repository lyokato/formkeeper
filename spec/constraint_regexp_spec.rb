# -*- encoding: utf-8 -*-
require 'spec_helper'

describe FormKeeper::Constraint::Regexp do

  it "validate value correctly" do

    constraint = FormKeeper::Constraint::Regexp.new
    constraint.validate('this is ruby', %r{ruby}).should be_true
    constraint.validate('this is perl', %r{ruby}).should_not be_true

  end

end
