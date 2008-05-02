require "#{File.expand_path(File.dirname(__FILE__) + "/../../../../")}/config/boot.rb"
require 'rubygems'
require 'spec'
require 'active_support'
require 'active_record'
require 'ostruct'
require File.dirname(__FILE__) + '/../lib/has_accent.rb'
ActiveRecord::Base.send(:include, HasAccent::Localize)

Spec::Runner.configure do |config|
  config.mock_with :mocha
end

class MockedModel < ActiveRecord::Base
  
  def self.add_column(name, type = :string)
    returning ActiveRecord::ConnectionAdapters::Column.new(name, nil) do |column|
      column.stubs(:type).returns(type)
      @columns ||= []
      @columns << column
    end
  end
  
  def self.reset_columns
    @columns = []
  end
  
  def self.clear_method(name)
    remove_method(name)
  end

  def self.columns
    @columns || []
  end
  
  def self.content_columns
    @columns || []
  end
  
  def self.inspect
    "Model Mock"
  end

  def self.table_name
    'mocked_models'
  end
end