# -*- encoding: utf-8 -*-
require 'spec_helper'

describe FormKeeper::Constraint::URI do

  it "validate value correctly" do

    constraint = FormKeeper::Constraint::URI.new
    constraint.validate('aaaa', :http).should_not eql(true)
    constraint.validate('http://example.org/', :http).should eql(true)
    constraint.validate('http://example.org/', [:http]).should eql(true)
    constraint.validate('https://example.org/', [:http]).should_not eql(true)
    constraint.validate('http://example.org/', [:http, :https]).should eql(true)
    constraint.validate('https://example.org/', [:http, :https]).should eql(true)

    constraint.validate('aaaa', :http).should_not eql(true)
    constraint.validate('aaa', [:http, :https]).should_not eql(true)

  end

end
