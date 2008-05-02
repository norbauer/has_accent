$:.unshift(File.dirname(__FILE__))
require 'has_accent/localize'
require 'has_accent/translation'

module HasAccent
   
  mattr_writer :default_language
  def self.default_language
    @@default_language ||= :en
  end

  mattr_writer :languages
  def self.languages
    @@languages ||= (gibberish_languages || [default_language])
  end
  
  mattr_writer :current_language
  def self.current_language
    @@current_language || default_language
  end
  
  def self.translatable_types
    Translation.translatable_types 
  end
  
  def self.validated_translations(class_name = nil)
    class_name ? Translation.validated.by_type(class_name) : Translation.validated
  end
  
  def self.pending_translations(class_name = nil)
    class_name ? Translation.pending.by_type(class_name) : Translation.pending
  end
  
  def self.dirty_translations(class_name = nil)
    class_name ? Translation.dirty.by_type(class_name) : Translation.dirty
  end
  
  def self.pending_and_dirty_translations(class_name = nil)
    class_name ? Translation.pending_and_dirty.by_type(class_name) : Translation.pending_and_dirty
  end
  
  private
  def self.gibberish_languages
    defined?(Gibberish) && Gibberish.respond_to?(:languages) ? Gibberish.languages : nil
  end
  
end