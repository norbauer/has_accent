## HasAccent

HasAccent is an internalization plugin for Ruby on Rails.  It allows you to easily store and retrieve translations of any of your AR model's string/text fields in the database.

## Requirements

Rails 2.1+ is required for this plugin.

## Installation

* Sitting in your Rails app root folder: `./script/plugin install git@github.com:norbauer/has_accent.git`
* Generate the required migrations with: `./script/generate translatable`
* Run: `rake db:migrate`
   
## Configuration

* Open up `environment.rb` and create a list of available languages.  It's recommended to use the language code instead of the full name:

<pre>
HasAccent.languages = [:en, :es, :fr]
</pre>

* The HasAccent's default language is english, this means that HasAccent will treat the actual values stored in the ActiveRecord instance as being in English, but you can override this setting.  For example, if you want to make French the default language:

<pre>
HasAccent.default_language = :fr
</pre>

* Add the `has_accent` call on any of your ActiveRecord models for which you wish to enable translations, by default all the string/text attributes will be set as translatable.

<pre>
class Product < ActiveRecord::Base
  has_accent
end
</pre>

* You can also override these default settings:

<pre>
class Product < ActiveRecord::Base
  has_accent :name, :description
end
</pre>

* Once `has_accent` has been set, anytime you create a new record, HasAccent will create empty translation stubs for each of the languages.  You can access these translations by calling `translations` on a record (using the example above):

<pre>
@product = Product.find_by_id(params[:id])
@translations = @product.translations # Returns all translations
@translations = @product.translations.pending # Returns pending translations, those which are just stubs (empty)
@translations = @product.translations.dirty # Returns all translations that might be out of date because the original attribute was modified.
</pre>

The Translation model attributes are: 

1. content - Stores the actual text translation.

2. translatable_attribute - Stores the name of the attribute that this translation is linked to (Using the example above, either 'name' or 'description')

3. language -  Stores the language name or code, depending on how you set them up during the configuration ('en', 'fr', 'es', etc...)

## Instructions

* Add a `before_filter` in any of your Rails controllers to set the current language, ideally in your ApplicationController:

<pre>
class ApplicationController < ActionController::Base
  before_filter :set_current_langauge
  
  def set_current_language
    lang = # Here goes the logic where you decide which is the current language
    HasAcent.current_language = lang
  end
end
</pre>

* HasAccent will give you a set of dynamic methods that you can use in your views to return the correct translation based on `HasAccent.current_language` setting.  Using the example above and assuming all translations have been entered:

<pre>
HasAccent.current_language = :en
@product.name # => 'Car'
@product.translated_name # => 'Car'

HasAccent.current_language = :es
@product.name # => 'Car'
@product.translated_name # => 'Carro'

HasAccent.current_language = :fr
@product.name # => 'Car'
@product.translated_name # => 'Voiture'
</pre>

---
Copyright (c) 2008 Norbauer Inc, released under the MIT license<br/>
Written by Jose Fernandez and Ryan Norbauer, with support from The Sequoyah Group