require 'spec_helper'

describe FormKeeper::Validator do

  it "validates valid params according to rule" do

    rule = FormKeeper::Rule.new
    rule.filters :strip
    rule.field :username, :present => true, :length => 8..16
    rule.field :password, :present => true, :length => 8..16
    rule.field :nickname, :bytesize => 8..16, :filters => :upcase

    params = {}
    params['username'] = '  hogehogefoo'
    params['password'] = 'hogehogebar '
    params['nickname'] = 'hogehoge buz'

    validator = FormKeeper::Validator.new
    report = validator.validate(params, rule)

    report.failed?.should_not be_true

    report[:username].should == 'hogehogefoo'
    report[:password].should == 'hogehogebar'
    report[:nickname].should == 'HOGEHOGE BUZ'

  end

  it "validates unpresent params according to rule" do

    rule = FormKeeper::Rule.new
    rule.filters :strip
    rule.field :username, :present => true, :length => 8..16
    rule.field :password, :present => true, :length => 8..16
    rule.field :nickname, :bytesize => 8..16, :filters => :upcase

    params = {}
    params['username'] = '  hogehogefoo'
    params['nickname'] = 'hogehoge buz'

    validator = FormKeeper::Validator.new
    report = validator.validate(params, rule)

    #valid_params.keys.size.should == 2
    report[:username].should == 'hogehogefoo'
    report[:nickname].should == 'HOGEHOGE BUZ'

    report.failed?.should be_true
    report.failed_on?(:password).should be_true

  end

  it "validates checkbox params" do

    rule = FormKeeper::Rule.new
    rule.filters :strip
    rule.field :username, :present => true, :length => 8..16
    rule.field :password, :present => true, :length => 8..16
    rule.checkbox :colors, :count => 1..3

    params = {}
    params['username'] = '  hogehogefoo'
    params['password'] = 'hogehogebar '
    params['colors'] = ['white', 'black', 'blue']

    validator = FormKeeper::Validator.new
    report = validator.validate(params, rule)

    report.failed?.should_not be_true
    #valid_params.keys.size.should == 3
    report[:username].should == 'hogehogefoo'
    report[:password].should == 'hogehogebar'
    report[:colors].should == ['white', 'black', 'blue']

  end

  it "validates invalid checkbox params" do

    rule = FormKeeper::Rule.new
    rule.filters :strip
    rule.field :username, :present => true, :length => 8..16
    rule.field :password, :present => true, :length => 8..16
    rule.checkbox :colors, :count => 1..2

    params = {}
    params['username'] = '  hogehogefoo'
    params['password'] = 'hogehogebar '
    params['colors'] = ['white', 'black', 'blue']

    validator = FormKeeper::Validator.new
    report = validator.validate(params, rule)

    #valid_params.keys.size.should == 2
    report[:username].should == 'hogehogefoo'
    report[:password].should == 'hogehogebar'

    report.failed?.should be_true
  end

  it "validates empty checkbox params" do

    rule = FormKeeper::Rule.new
    rule.filters :strip
    rule.field :username, :present => true, :length => 8..16
    rule.field :password, :present => true, :length => 8..16
    rule.checkbox :colors, :count => 1..2

    params = {}
    params['username'] = '  hogehogefoo'
    params['password'] = 'hogehogebar '
    params['colors'] = []

    validator = FormKeeper::Validator.new
    report = validator.validate(params, rule)

    #valid_params.keys.size.should == 2
    report[:username].should == 'hogehogefoo'
    report[:password].should == 'hogehogebar'

    report.failed?.should be_true

  end

  it "validates filtered-empty checkbox params" do

    rule = FormKeeper::Rule.new
    rule.filters :strip
    rule.field :username, :present => true, :length => 8..16
    rule.field :password, :present => true, :length => 8..16
    rule.checkbox :colors, :count => 1..2

    params = {}
    params['username'] = '  hogehogefoo'
    params['password'] = 'hogehogebar '
    params['colors'] = [' ']

    validator = FormKeeper::Validator.new
    report = validator.validate(params, rule)

    #valid_params.keys.size.should == 2
    report[:username].should == 'hogehogefoo'
    report[:password].should == 'hogehogebar'

    report.failed?.should be_true

  end

  it "validates checkbox params with constraint" do

    rule = FormKeeper::Rule.new
    rule.filters :strip
    rule.field :username, :present => true, :length => 8..16
    rule.field :password, :present => true, :length => 8..16
    rule.checkbox :colors, :count => 1..2, :length => 4..5

    params = {}
    params['username'] = '  hogehogefoo'
    params['password'] = 'hogehogebar '
    params['colors'] = [' white', 'black']

    validator = FormKeeper::Validator.new
    report = validator.validate(params, rule)

    #valid_params.keys.size.should == 3
    report[:username].should == 'hogehogefoo'
    report[:password].should == 'hogehogebar'
    report[:colors].should == ['white', 'black']

    report.failed?.should_not be_true

  end

  it "validates invalid checkbox params with constraint" do

    rule = FormKeeper::Rule.new
    rule.filters :strip
    rule.field :username, :present => true, :length => 8..16
    rule.field :password, :present => true, :length => 8..16
    rule.checkbox :colors, :count => 1..2, :length => 4..5

    params = {}
    params['username'] = '  hogehogefoo'
    params['password'] = 'hogehogebar '
    params['colors'] = [' white', 'black', 'red']

    validator = FormKeeper::Validator.new
    report = validator.validate(params, rule)

    #valid_params.keys.size.should == 2
    report[:username].should == 'hogehogefoo'
    report[:password].should == 'hogehogebar'

    report.failed?.should be_true
    report.failed_on?(:colors)
  end

  it "validates combination params" do

    rule = FormKeeper::Rule.new
    rule.filters :strip
    rule.field :username, :present => true, :length => 8..16
    rule.field :password, :present => true, :length => 8..16
    rule.combination :same_email_address, :fields => [:email1, :email2], :same => true

    params = {}
    params['username'] = '  hogehogefoo'
    params['password'] = 'hogehogebar '
    params['email1'] = 'hoge@example.org'
    params['email2'] = 'hoge@example.org'

    validator = FormKeeper::Validator.new
    report = validator.validate(params, rule)

    #valid_params.keys.size.should == 2
    report[:username].should == 'hogehogefoo'
    report[:password].should == 'hogehogebar'

    report.failed?.should_not be_true

  end

  it "validates combination params by synonym" do

    rule = FormKeeper::Rule.new
    rule.filters :strip
    rule.field :username, :present => true, :length => 8..16
    rule.field :password, :present => true, :length => 8..16
    rule.same :same_email_address, [:email1, :email2], :filters => :upcase

    params = {}
    params['username'] = '  hogehogefoo'
    params['password'] = 'hogehogebar '
    params['email1'] = 'hoge@example.org'
    params['email2'] = 'hoge@example.org'

    validator = FormKeeper::Validator.new
    report = validator.validate(params, rule)

    #valid_params.keys.size.should == 2
    report[:username].should == 'hogehogefoo'
    report[:password].should == 'hogehogebar'

    report.failed?.should_not be_true

  end

  it "validates invalid combination params" do

    rule = FormKeeper::Rule.new
    rule.filters :strip
    rule.field :username, :present => true, :length => 8..16
    rule.field :password, :present => true, :length => 8..16
    rule.same :same_email_address, [:email1, :email2], :filters => :upcase

    params = {}
    params['username'] = '  hogehogefoo'
    params['password'] = 'hogehogebar '
    params['email1'] = 'hoge@example.org'
    params['email2'] = 'hoge2@example.org'

    validator = FormKeeper::Validator.new
    report = validator.validate(params, rule)

    #valid_params.keys.size.should == 2
    report[:username].should == 'hogehogefoo'
    report[:password].should == 'hogehogebar'

    report.failed?.should be_true
    report.failed_on?(:same_email_address).should be_true

  end
end

