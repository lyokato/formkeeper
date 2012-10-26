# -*- encoding: utf-8 -*-
require 'spec_helper'

describe FormKeeper::Filter::ToUTF8 do

  it "handles utf-8 value correctly" do

    value = File.open(File.dirname(__FILE__) + '/asset/utf8.txt') { |f| f.read.chomp }
    filter = FormKeeper::Filter::ToUTF8.new('UTF-8')
    filter.process(value).should == "ほげほげ";
  end

  it "handles invalid encoding value correctly" do

    value = File.open(File.dirname(__FILE__) + '/asset/euc.txt') { |f| f.read.chomp }
    filter = FormKeeper::Filter::ToUTF8.new('Shift_JIS')
    filter.process(value).should_not == "ほげほげ";
  end

  it "handles euc-jp value correctly" do

    value = File.open(File.dirname(__FILE__) + '/asset/euc.txt') { |f| f.read.chomp }
    filter = FormKeeper::Filter::ToUTF8.new('EUC-JP')
    filter.process(value).should == "ほげほげ"
  end

end
