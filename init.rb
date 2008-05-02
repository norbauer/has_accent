require 'has_accent'
require 'activesupport'
ActiveRecord::Base.send(:include, HasAccent::Localize)