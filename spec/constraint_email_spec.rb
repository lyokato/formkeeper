# -*- encoding: utf-8 -*-
require 'spec_helper'

describe FormKeeper::Constraint::Email do

  it "validate value correctly" do
    constraint = FormKeeper::Constraint::Email.new
    constraint.validate('lyo.kato@gmail.com', true).should eql(true)
    constraint.validate('foo.foo.foo@docomo.ne.jp', true).should eql(true)
    constraint.validate('foo.@docomo.ne.jp', true).should eql(true)
    constraint.validate('foo..foo@docomo.ne.jp', true).should eql(true)
    constraint.validate('lyo.kato', true).should_not eql(true)
    constraint.validate('foo@', true).should_not eql(true)
    constraint.validate('@foo', true).should_not eql(true)
    constraint.validate('.foo@example.com', true).should_not eql(true)
    constraint.validate('foo[@example.com', true).should_not eql(true)
    constraint.validate('foo @example.com', true).should_not eql(true)
  end

end
