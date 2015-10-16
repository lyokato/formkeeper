#--
# Copyright (C) 2012 Lyo Kato, <lyo.kato _at_ gmail.com>.
#
# Permission is hereby granted, free of charge, to any person obtaining 
# a copy of this software and associated documentation files (the 
# "Software"), to deal in the Software without restriction, including 
# without limitation the rights to use, copy, modify, merge, publish, 
# distribute, sublicense, and/or sell copies of the Software, and to 
# permit persons to whom the Software is furnished to do so, subject to 
# the following conditions: 
#
# The above copyright notice and this permission notice shall be 
# included in all copies or substantial portions of the Software. 
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 

require "formkeeper/version"
require 'hpricot'
require 'yaml'
require 'rack'
require 'uri'
require 'date'

module FormKeeper
  module Filter
    class Base
      def process(value)
        return value
      end
    end

    class Custom < Base
      def initialize(block)
        @custom = block
      end
      def process(value)
        @custom.call(value) 
      end
    end

    class ToUTF8 < Base
      def initialize(encoding)
        @encoding = encoding
      end
      def process(value)
        v = value.dup
        v.force_encoding(@encoding)
        return v.encode('UTF-8') if v.valid_encoding?
        value.encode('UTF-16', :invalid => :replace, :undef => :replace, :replace => '').encode('UTF-8')
      end
    end

    class UpCase < Base
      def process(value)
        return value.upcase
      end
    end

    class DownCase < Base
      def process(value)
        return value.downcase
      end
    end

    class Strip < Base
      def process(value)
        return value.strip
      end
    end

    class Capitalize < Base
      def process(value)
        return value.capitalize
      end
    end
  end

  module Constraint
    class Base
      def validate(value, arg)
        return true
      end
    end

    class Custom < Base
      def initialize(block)
        @custom = block
      end
      def validate(value, arg)
        @custom.call(value, arg) 
      end
    end

    class Ascii < Base
      def validate(value, arg)
        result = value =~ /^[\x21-\x7e]+$/
        result = !result if !arg
        !!result
      end
    end

    class AsciiSpace < Base
      def validate(value, arg)
        result = value =~ /^[\x20-\x7e]+$/
        result = !result if !arg
        !!result
      end
    end

    class Regexp < Base
      def validate(value, arg)
        r = arg
        r = ::Regexp.new(r) unless r.kind_of?(::Regexp)
        !!(value =~ r)
      end
    end

    class Int < Base
      def validate(value, arg)
        result = value =~ /^\-?[[:digit:]]+$/
        if result and arg.kind_of?(Hash)
          if arg.has_key?(:gt)
            unless arg[:gt].kind_of?(Fixnum)
              raise ArgumentError.new ':gt should be Fixnum'
            end
            return false unless value.to_i > arg[:gt];
          end
          if arg.has_key?(:gte)
            unless arg[:gte].kind_of?(Fixnum)
              raise ArgumentError.new ':gte should be Fixnum'
            end
            return false unless value.to_i >= arg[:gte];
          end
          if arg.has_key?(:lt)
            unless arg[:lt].kind_of?(Fixnum)
              raise ArgumentError.new ':lt should be Fixnum'
            end
            return false unless value.to_i < arg[:lt];
          end
          if arg.has_key?(:lte)
            unless arg[:lte].kind_of?(Fixnum)
              raise ArgumentError.new ':lte should be Fixnum'
            end
            return false unless value.to_i <= arg[:lte];
          end
          if arg.has_key?(:between)
            unless arg[:between].kind_of?(Range)
              raise ArgumentError.new ':between should be Range'
            end
            return false unless arg[:between].include?(value.to_i);
          end
          true
        else
          result = !result if !arg
          !!result
        end
      end
    end

    class Uint < Base
      def validate(value, arg)
        result = value =~ /^[[:digit:]]+$/
        if result and arg.kind_of?(Hash)
          if arg.has_key?(:gt)
            unless arg[:gt].kind_of?(Fixnum)
              raise ArgumentError.new ':gt should be Fixnum'
            end
            return false unless value.to_i > arg[:gt];
          end
          if arg.has_key?(:gte)
            unless arg[:gte].kind_of?(Fixnum)
              raise ArgumentError.new ':gte should be Fixnum'
            end
            return false unless value.to_i >= arg[:gte];
          end
          if arg.has_key?(:lt)
            unless arg[:lt].kind_of?(Fixnum)
              raise ArgumentError.new ':lt should be Fixnum'
            end
            return false unless value.to_i < arg[:lt];
          end
          if arg.has_key?(:lte)
            unless arg[:lte].kind_of?(Fixnum)
              raise ArgumentError.new ':lte should be Fixnum'
            end
            return false unless value.to_i <= arg[:lte];
          end
          if arg.has_key?(:between)
            unless arg[:between].kind_of?(Range)
              raise ArgumentError.new ':between should be Range'
            end
            return false unless arg[:between].include?(value.to_i);
          end
          true
        else
          result = !result if !arg
          !!result
        end
      end
    end

    class Alpha < Base
      def validate(value, arg)
        result = value =~ /^[[:alpha:]]+$/
        result = !result if !arg
        !!result
      end
    end

    class AlphaSpace < Base
      def validate(value, arg)
        result = value =~ /^[[:alpha:][:space:]]+$/
        result = !result if !arg
        !!result
      end
    end

    class Alnum < Base
      def validate(value, arg)
        result = value =~ /^[[:alnum:]]+$/
        result = !result if !arg
        !!result
      end
    end

    class AlnumSpace < Base
      def validate(value, arg)
        result = value =~ /^[[:alnum:][:space:]]+$/
        result = !result if !arg
        !!result
      end
    end

    class URI < Base
      def validate(value, arg)
        u = ::URI.parse(value)
        return false if u.nil?
        arg = [arg] unless arg.kind_of?(Array)
        arg.collect(&:to_s).include?(u.scheme)
      end
    end

    class Email < Base

      # borrowed from
      # http://blog.everqueue.com/chiba/2009/03/22/163/
      def build_regexp
        wsp              = '[\x20\x09]'
        vchar            = '[\x21-\x7e]'
        quoted_pair      = "\\\\(?:#{vchar}|#{wsp})"
        qtext            = '[\x21\x23-\x5b\x5d-\x7e]'
        qcontent         = "(?:#{qtext}|#{quoted_pair})"
        quoted_string    = "\"#{qcontent}*\""
        atext            = '[a-zA-Z0-9!#$%&\'*+\-\/\=?^_`{|}~]'
        dot_atom_text    = "#{atext}+(?:[.]#{atext}+)*"
        dot_atom         = dot_atom_text
        local_part       = "(?:#{dot_atom}|#{quoted_string})"
        domain           = dot_atom
        addr_spec        = "#{local_part}[@]#{domain}"
        dot_atom_loose   = "#{atext}+(?:[.]|#{atext})*"
        local_part_loose = "(?:#{dot_atom_loose}|#{quoted_string})"
        addr_spec_loose  = "#{local_part_loose}[@]#{domain}"
        addr_spec_loose
      end

      def regexp
        @regexp ||= build_regexp
      end

      def validate(value, arg)
        r = ::Regexp.new('^' + regexp + '$')
        !!(value =~ r)
      end

    end

    class Length < Base
      def validate(value, arg)
        l = value.length
        case arg
        when Fixnum
          return (l == arg)
        when Range
          return arg.include?(l)
        else
          raise ArgumentError, 'Invalid number of arguments'
        end
      end
    end

    class ByteSize < Base
      def validate(value, arg)
        l = value.bytesize
        case arg
        when Fixnum
          return (l == arg)
        when Range
          return arg.include?(l)
        else
          raise ArgumentError, 'Invalid number of arguments'
        end
      end
    end
  end

  module CombinationConstraint
    class Base
      def validate(values, arg)
        return true
      end
    end

    class Same < Base
      def validate(values, arg)
        return false unless values.size == 2
        values[0] == values[1]
      end
    end

    class Different < Base
      def validate(values, arg)
        return false unless values.size == 2
        values[0] != values[1]
      end
    end

    class Any < Base
      def validate(values, arg)
        values.any? { |v| not (v.nil? or v.empty?) }
      end
    end

    class Date < Base
      def validate(values, arg)
        return false unless values.size == 3
        return false unless values.all? { |v| v =~ /^[[:digit:]]+$/ }
        # TODO handle range by args[:from] and args[:to]
        ::Date.valid_date?(values[0].to_i, values[1].to_i, values[2].to_i)
      end
    end

    class Time < Base
      def validate(values, arg)
        return false unless values.size == 3
        return false unless values.all? { |v| v =~ /^[[:digit:]]+$/ }
        # TODO handle range by args[:from] and args[:to]
        (0..23).include?(values[0].to_i) and (0..59).include?(values[1].to_i) and (0..59).include?(values[2].to_i)
      end
    end

    class DateTime < Base
      def validate(values, arg)
        return false unless values.size == 6
        return false unless values.all? { |v| v =~ /^[[:digit:]]+$/ }
        # TODO handle range by args[:from] and args[:to]
        ::Date.valid_date?(values[0].to_i, values[1].to_i, values[2].to_i) and (0..23).include?(values[3].to_i) and (0..59).include?(values[4].to_i) and (0..59).include?(values[5].to_i)
      end
    end
  end 

  class Messages
    DEFAULT_ACTION_NAME     = 'DEFAULT'
    DEFAULT_CONSTRAINT_NAME = 'DEFAULT'
    def self.from_file(path)
      data = YAML.load_file(path)
      self.new(data)
    end
    def initialize(data)
      @data = data
    end
    def get(action_name, target_name, constraint_name)
      if @data.has_key?(action_name.to_s)
        action = @data[action_name.to_s]
        return search_from_action_part(action, target_name, constraint_name)
      else
        if @data.has_key?(DEFAULT_ACTION_NAME)
          action = @data[DEFAULT_ACTION_NAME]
          return search_from_action_part(action, target_name, constraint_name)
        else
          return handle_missing_message(target_name)
        end
      end
    end

    private
    def search_from_action_part(action, target_name, constraint_name)
      if action.has_key?(target_name.to_s)
        field = action[target_name.to_s]
        return search_from_field_part(target_name, field, constraint_name)
      else
        return handle_missing_message(target_name)
      end
    end

    def search_from_field_part(target_name, field, constraint_name)
      if field.has_key?(constraint_name.to_s)
        return field[constraint_name.to_s]
      else
        if field.has_key?(DEFAULT_CONSTRAINT_NAME)
          return field[DEFAULT_CONSTRAINT_NAME]
        else
          return handle_missing_message(target_name)
        end
      end
    end

    def handle_missing_message(target_name)
      build_default_message(target_name)
    end

    def build_default_message(target_name)
      "#{target_name.to_s} is invalid."
    end
  end

  class Record
    attr_reader :name, :failed_constraints
    attr_accessor :value
    def initialize(name)
      @name = name
      @value = nil
      @failed_constraints = []
    end
    def fail(constraint)
      @failed_constraints << constraint
    end
    def failed?
      @failed_constraints.size > 0
    end
    def failed_by?(constraint)
      @failed_constraints.include?(constraint.to_sym)
    end
  end

  class Report
    def initialize(messages=nil)
      @failed_records = {}
      @messages = messages || Messages.new({})
      @valid_params = {}
    end
    def <<(record)
      if record.failed?
        @failed_records[record.name.to_sym] = record
      else
        @valid_params[record.name.to_sym] = record.value
      end
    end
    def [](name)
      @valid_params[name.to_sym]
    end
    def value(name)
      name = name.to_sym
      return self[name] if valid?(name)
      failed_fields.include?(name) ? @failed_records[name].value : nil
    end
    def valid_fields
      @valid_params.keys
    end
    def valid?(name)
      @valid_params.has_key?(name.to_sym)
    end
    def failed?
      !@failed_records.empty?
    end
    def failed_on?(name, constraint=nil)
      return false unless @failed_records.has_key?(name.to_sym)
      return true if constraint.nil?
      record = @failed_records[name.to_sym]
      record.failed_by?(constraint)
    end
    def failed_fields
      @failed_records.keys 
    end
    def failed_constraints(name)
      return [] unless @failed_records.has_key?(name.to_sym)
      record = @failed_records[name.to_sym]
      record.failed_constraints
    end
    def messages(action, name=nil)
      messages = []
      if name.nil?
        @failed_records.values.each do |record|
          record.failed_constraints.each do |constraint|
            messages << @messages.get(action, record.name, constraint)
          end
        end
      else
        if @failed_records.has_key?(name.to_sym)
          record = @failed_records[name.to_sym]
          record.failed_constraints.each do |constraint|
            messages << @messages.get(action, record.name, constraint)
          end
        end
      end
      messages.select{ |m| !m.nil? and !m.empty? }.uniq
    end
    def message(action, name, constraint)
      if @failed_records.has_key?(name.to_sym) and @failed_records[name.to_sym].failed_by?(constraint)
        @messages.get(action, name, constraint)
      else
        nil
      end
    end
  end

  class Rule
    module Criteria
      class Field
        attr_reader :default, :filters, :constraints
        def initialize(criteria)
          if criteria.has_key?(:default)
            default = criteria.delete :default
            @default = default.empty? ? nil : default
          else
            @default = nil
          end
          if criteria.has_key?(:filters)
            filters = criteria.delete :filters
            case filters
            when Array
              @filters = filters.collect(&:to_sym)
            when String
              @filters = [filters.to_sym]
            when Symbol
              @filters = [filters]
            else
              raise ArgumentError.new 'invalid :filters'
            end
          else
            @filters = []
          end

          if criteria.has_key?(:present)
            if not @default.nil?
              raise ArgumentError.new "don't set both :default and :present at once"
            end
            present = criteria.delete :present
            @present = !!present
          else
            @present = false
          end
          @constraints = criteria
        end

        def require_presence?
          @present
        end
      end

      class Checkbox
        attr_reader :default, :filters, :count, :constraints
        def initialize(criteria)
          if criteria.has_key?(:default)
            default = criteria.delete :default
            case default
            when Array
              @default = default.collect(&:to_s)
            else
              @default = [default.to_s]
            end
          else
            @default = []
          end

          if criteria.has_key?(:filters)
            filters = criteria.delete :filters
            case filters
            when Array
              @filters = filters.collect(&:to_sym)
            when String
              @filters = [filters.to_sym]
            when Symbol
              @filters = [filters]
            else
              raise ArgumentError.new 'invalid :filters'
            end
          else
            @filters = []
          end
          if criteria.has_key?(:count)
            count = criteria.delete :count
            case count
            when Fixnum
              @count = Range.new(count, count)
            when Range
              @count = count
            else
              raise ArgumentError.new 'invalid :count'
            end
          else
            @count = nil
          end
          @constraints = criteria
        end
      end

      class Combination
        attr_reader :fields, :filters, :constraint, :arg
        def initialize(criteria)
          if criteria.has_key?(:fields)
            fields = criteria.delete(:fields)
            if fields.kind_of?(Array) && fields.size >= 2
              @fields = fields.collect(&:to_sym)
            else
              raise ArgumentError.new("combination rule requires :fields as array which include 2 fields at lease")
            end
          else
            raise ArgumentError.new("combination rule requires :fields")
          end
          if criteria.has_key?(:filters)
            filters = criteria.delete :filters
            case filters
            when Array
              @filters = filters.collect(&:to_sym)
            when String
              @filters = [filters.to_sym]
            when Symbol
              @filters = [filters]
            else
              raise ArgumentError.new 'invalid :filters'
            end
          else
            @filters = []
          end
          constraint = criteria.shift
          if constraint.nil?
            raise ArgumentError.new 'constraint not found'
          else
            @constraint = constraint[0]
            @arg = constraint[1]
          end
        end
      end
    end

    attr_reader :default_filters, :fields, :checkboxes, :combinations, :encoding_filter

    def initialize
      @default_filters = []
      @encoding_filter = nil
      @fields = {}
      @checkboxes = {}
      @combinations = {}
    end

    def encoding(code)
      @encoding_filter = Filter::ToUTF8.new(code)
    end

    def filters(*args)
      @default_filters = args
    end

    def field(name, criteria)
      raise ArgumentError.new unless criteria.kind_of?(Hash)
      @fields[name.to_sym] = Criteria::Field.new(criteria)
    end

    def selection(name, criteria)
      raise ArgumentError.new unless criteria.kind_of?(Hash)
      @checkboxes[name.to_sym] = Criteria::Checkbox.new(criteria)
    end

    # for backward-compatibility
    alias_method :checkbox, :selection

    def combination(name, criteria)
      raise ArgumentError.new unless criteria.kind_of?(Hash)
      @combinations[name.to_sym] = Criteria::Combination.new(criteria)
    end

    def method_missing(name, *args)
      rule = args[0]
      criteria = {}
      criteria[:fields] = args[1]
      opts = args[2] || {}
      if opts.has_key?(:filters)
        criteria[:filters] = opts.delete(:filters)
      end
      if opts.empty? 
        criteria[name.to_sym] = true
      else
        criteria[name.to_sym] = opts
      end
      combination(rule, criteria)
    end
  end

  class Validator
    
    @@filter_store = {}
    @@constraint_store = {}
    @@combination_constraint_store = {}

    def self.register_filter(name, filter)
      @@filter_store[name] = filter
    end

    def self.register_constraint(name, constraint)
      @@constraint_store[name] = constraint
    end

    def self.register_combination_constraint(name, constraint)
      @@combination_constraint_store[name] = constraint
    end

    register_filter :strip, Filter::Strip.new
    register_filter :downcase, Filter::DownCase.new
    register_filter :upcase, Filter::UpCase.new
    register_filter :capitalize, Filter::Capitalize.new

    register_constraint :ascii, Constraint::Ascii.new
    register_constraint :ascii_space, Constraint::AsciiSpace.new
    register_constraint :regexp, Constraint::Regexp.new
    register_constraint :int, Constraint::Int.new
    register_constraint :uint, Constraint::Uint.new
    register_constraint :alpha, Constraint::Alpha.new
    register_constraint :alpha_space, Constraint::AlphaSpace.new
    register_constraint :alnum, Constraint::Alnum.new
    register_constraint :alnum_space, Constraint::AlnumSpace.new
    register_constraint :uri, Constraint::URI.new
    register_constraint :email, Constraint::Email.new
    register_constraint :length, Constraint::Length.new
    register_constraint :bytesize, Constraint::ByteSize.new

    register_combination_constraint :datetime, CombinationConstraint::DateTime.new
    register_combination_constraint :date, CombinationConstraint::Date.new
    register_combination_constraint :time, CombinationConstraint::Time.new
    register_combination_constraint :same, CombinationConstraint::Same.new
    register_combination_constraint :diff, CombinationConstraint::Different.new
    register_combination_constraint :any, CombinationConstraint::Any.new

    def initialize
    end

    def validate(params, rule, messages=nil)
      report = Report.new(messages)
      rule.fields.each do |name, criteria|
        criteria.filters.concat(rule.default_filters)
        report << validate_field(name, criteria, params, rule.encoding_filter)
      end
      rule.checkboxes.each do |name, criteria|
        criteria.filters.concat(rule.default_filters)
        report << validate_checkbox(name, criteria, params, rule.encoding_filter)
      end
      rule.combinations.each do |name, criteria|
        criteria.filters.concat(rule.default_filters)
        report << validate_combination(name, criteria, params, rule.encoding_filter)
      end
      return report
    end

    private
    def validate_combination(name, criteria, params, encoding)
      record = Record.new(name)
      values = criteria.fields.collect { |name| params[name.to_s] }
      values = filter_combination_values(values, criteria.filters, encoding)
      constraint = find_combination_constraint(criteria.constraint)
      result = constraint.validate(values, criteria.arg)
      record.fail(name) unless result
      record
    end

    def validate_checkbox(name, criteria, params, encoding)
      record = Record.new(name)
      if params.has_key?(name.to_s)
        values = params[name.to_s]
        if values.kind_of?(Array) 
          values = filter_checkbox_values(values, criteria.filters, encoding)
          record.value = values
          if criteria.count.nil?
            if values.size == 0 
              handle_missing_checkbox(criteria, record)
            else
              values.each do |value|
                validate_value(value, criteria, record)
              end
            end
          else
            if criteria.count.include?(values.size)
              values.each do |value|
                validate_value(value, criteria, record)
              end
            else
              if values.size == 0 
                handle_missing_checkbox(criteria, record)
              else
                record.fail(:count)
              end
            end
          end
        else
          handle_missing_checkbox(criteria, record)
        end
      else
        handle_missing_checkbox(criteria, record)
      end
      record
    end

    def filter_combination_values(values, filters, encoding)
      values = values.collect{ |v| filter_value(v, filters, encoding) }
      values
    end

    def filter_checkbox_values(values, filters, encoding)
      values = filter_combination_values(values, filters, encoding)
      values.delete_if { |v| v.nil? or v.empty? }
      values
    end

    def handle_missing_checkbox(criteria, record)
      if criteria.default.empty?
        record.fail(:count) unless criteria.count.nil?
      else
        record.value = criteria.default
      end
    end

    def validate_field(name, criteria, params, encoding)
      record = Record.new name
      if params.has_key?(name.to_s)
        value = params[name.to_s]
        unless value.kind_of?(Array)
          value = filter_field_value(value, criteria.filters, encoding)
          record.value = value
          if value.empty?
            handle_missing_field(criteria, record)
          else
            validate_value(value, criteria, record)
          end
        else
          handle_missing_field(criteria, record)
        end
      else
        handle_missing_field(criteria, record)
      end
      record
    end

    def filter_field_value(value, filters, encoding)
      filter_value(value, filters, encoding)
    end

    def handle_missing_field(criteria, record)
      if criteria.default.nil?
        record.fail(:present) if criteria.require_presence?
      else
        record.value = criteria.default
      end
    end

    def find_filter(type)
      raise ArgumentError.new("unknown filter type: %s" % type) unless @@filter_store.has_key?(type)
      @@filter_store[type]
    end

    def find_constraint(type)
      raise ArgumentError.new("unknown constraint type: %s" % type) unless @@constraint_store.has_key?(type)
      @@constraint_store[type]
    end

    def find_combination_constraint(type)
      raise ArgumentError.new("unknown combination constraint type: %s" % type) unless @@combination_constraint_store.has_key?(type)
      @@combination_constraint_store[type]
    end

    def filter_value(value, filters, encoding)
      value = encoding.process(value) unless encoding.nil?
      filters.each { |f| value = find_filter(f).process(value) }
      value
    end

    def validate_value(value, criteria, record)
      criteria.constraints.each do |constraint, arg|
        result = find_constraint(constraint).validate(value, arg)
        record.fail(constraint) unless result
      end
    end
  end

  class Respondent

    def initialize
      replace_method = Proc.new { |elem, param| replase_value(elem, param) }
      check_method   = Proc.new { |elem, param| check_if_selected(elem, param) }
      @input_elem_fill_methods = {} 
      @input_elem_fill_methods[:text] = replace_method
      @input_elem_fill_methods[:password] = replace_method
      @input_elem_fill_methods[:hidden] = replace_method
      @input_elem_fill_methods[:search] = replace_method
      @input_elem_fill_methods[:number] = replace_method
      @input_elem_fill_methods[:range] = replace_method
      @input_elem_fill_methods[:tel] = replace_method
      @input_elem_fill_methods[:url] = replace_method
      @input_elem_fill_methods[:email] = replace_method
      @input_elem_fill_methods[:time] = replace_method
      @input_elem_fill_methods[:date] = replace_method
      @input_elem_fill_methods[:week] = replace_method
      @input_elem_fill_methods[:color] = replace_method
      @input_elem_fill_methods[:datetime] = replace_method
      @input_elem_fill_methods[:"datetime-local"] = replace_method
      @input_elem_fill_methods[:radio] = check_method
      @input_elem_fill_methods[:checkbox] = check_method
    end

    def fill_up(str, params)
      doc = Hpricot(str)
      (doc/"input").each do |elem|
        name = elem[:name]
        next if name.nil?
        name = name.sub(/\[\]$/, '');
        next unless params.has_key?(name.to_s)
        type = elem[:type]
        next if type.nil?
        next unless @input_elem_fill_methods.has_key?(type.to_sym)
        @input_elem_fill_methods[type.to_sym].call(elem, params[name.to_s])
      end
      (doc/"select").each do |select_elem|
        name = select_elem[:name]
        next if name.nil?
        name = name.sub(/\[\]$/, '');
        next unless params.has_key?(name.to_s)
        param = params[name.to_s]
        multiple = select_elem.has_attribute?(:multiple)
        can_select_more = true
        (select_elem/"option").each do |option_elem|
          value = option_elem[:value]
          next if value.nil? or value.empty?
          case param
          when Array
            if can_select_more and param.include?(value)
              option_elem[:selected] = "selected"
              can_select_more = false unless multiple
            else
              option_elem.remove_attribute(:selected)
            end
          when String
            if can_select_more and param == value
              option_elem[:selected] = "selected"
              can_select_more = false unless multiple
            else
              option_elem.remove_attribute(:selected)
            end
          else 
            if can_select_more and param.to_s == value
              option_elem[:selected] = "selected"
              can_select_more = false unless multiple
            else
              option_elem.remove_attribute(:selected)
            end
          end
        end
      end
      (doc/"textarea").each do |elem|
        name = elem[:name]
        next if name.nil?
        next unless params.has_key?(name.to_s)
        param = params[name.to_s]
        if param.kind_of?(Array)
          elem.innerHTML = Rack::Utils::escape_html(param[0])
        else
          elem.innerHTML = Rack::Utils::escape_html(param)
        end
      end
      doc.to_html
    end

    private
    def check_if_selected(elem, param)
      value = elem[:value]
      if value.nil?
        value = ''
      end
      if param.kind_of?(Array)
        if param.collect(&:to_s).include?(value)
          elem[:checked] = 'checked'
        else
          elem.remove_attribute('checked')
        end
      else
        if value == param.to_s
          elem[:checked] = 'checked'
        else
          elem.remove_attribute('checked')
        end
      end
    end

    def replase_value(elem, param)
      if param.kind_of?(Array)
        elem[:value] = param[0]
      else
        elem[:value] = param
      end
    end
  end

end
