require 'spec_helper'

describe FormKeeper::Rule do

  it "handles default filter correctly" do

    rule = FormKeeper::Rule.new
    rule.filters :strip

    rule.default_filters[0].should == :strip

    rule.filters :upcase, :downcase
    rule.default_filters[0].should == :upcase
    rule.default_filters[1].should == :downcase
  end

  it "handles field criteria correctly" do

    rule = FormKeeper::Rule.new

    # missing parameters
    proc {
      rule.field :field01
    }.should raise_error(ArgumentError)

    proc {
      rule.field :field01, {}
    }.should_not raise_error

    proc {
      rule.field :field01, :present => true
    }.should_not raise_error

    proc {
      rule.field :field01, :default => 'foobar'
    }.should_not raise_error

    # don't set present and default at once
    proc {
      rule.field :username, :present => true, :default => 'foobar'
    }.should raise_error(ArgumentError)

    proc {
      rule.field :field01, :default => 'foobar', :filters => [:strip]
    }.should_not raise_error

    proc {
      rule.field :field01, :default => 'foobar', :filters => :strip
    }.should_not raise_error

    # invalid filters
    proc {
      rule.field :username, :present => true, :filters => { :foo => 'bar' }
    }.should raise_error(ArgumentError)

    proc {
      rule.field :field01, :default => 'foobar', :length => 0..10
    }.should_not raise_error

  end

  it "handles checkbox criteria correctly" do

    rule = FormKeeper::Rule.new

    proc {
      rule.checkbox :field01
    }.should raise_error(ArgumentError)

    proc {
      rule.checkbox :field01, {}
    }.should_not raise_error

    proc {
      rule.checkbox :field01, :count => 1
    }.should_not raise_error

    proc {
      rule.checkbox :field01, :count => 0..2
    }.should_not raise_error

    proc {
      rule.checkbox :field01, :count => 'hoge'
    }.should raise_error(ArgumentError)

    proc {
      rule.checkbox :field01, :count => 1, :length => 0..10
    }.should_not raise_error

    proc {
      rule.checkbox :field01, :count => 1, :length => 0..10, :filters => [:strip]
    }.should_not raise_error

    proc {
      rule.checkbox :field01, :count => 1, :length => 0..10, :filters => :strip
    }.should_not raise_error

    # invalid filters
    proc {
      rule.checkbox :username, :count => 1, :filters => { :foo => 'bar' }
    }.should raise_error(ArgumentError)
  end

  it "handles combination criteria correctly" do

    rule = FormKeeper::Rule.new
    proc {
      rule.combination :custom 
    }.should raise_error

    # missing constraint
    proc {
      rule.combination :custom, :fields => [:field01, :field02]
    }.should raise_error(ArgumentError)

    # missing fields
    proc {
      rule.combination :custom, :date => true
    }.should raise_error(ArgumentError)

    proc {
      rule.combination :custom, :fields => [:field01, :field02], :date => true
    }.should_not raise_error

    proc {
      rule.combination :custom, :fields => [:field01, :field02], :date => true, :filters => [:strip]
    }.should_not raise_error

    proc {
      rule.combination :custom, :fields => [:field01, :field02], :date => true, :filters => :strip
    }.should_not raise_error

    proc {
      rule.combination :custom, :fields => [:field01, :field02], :date => true, :filters => {}
    }.should raise_error(ArgumentError)
  end

end
