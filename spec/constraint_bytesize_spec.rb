# -*- encoding: utf-8 -*-
require 'spec_helper'

describe FormKeeper::Constraint::ByteSize do

  it "validate value correctly" do

    constraint = FormKeeper::Constraint::ByteSize.new
    constraint.validate('aaaa', 0..10).should be_true
    constraint.validate('aaaa', 0..3).should_not be_true
    constraint.validate('aaaa', 4).should be_true
    constraint.validate('aaaa', 3).should_not be_true

    constraint.validate('ほげ', 2).should_not be_true

  end

end
