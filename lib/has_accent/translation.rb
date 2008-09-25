class Translation < ActiveRecord::Base
  partial_updadates = true
  belongs_to :translatable, :polymorphic => true
  validates_presence_of :language, :translatable_attribute
  validates_uniqueness_of :language, :scope => [:translatable_type, :translatable_id, :translatable_attribute]
  before_save :validate_translation
  
  # has_finder
  named_scope :validated, :conditions => { :validated => true }
  named_scope :pending_and_dirty, :conditions => { :validated => false }
  named_scope :dirty, :conditions => ["validated = FALSE AND content != '' && content IS NOT NULL"]
  named_scope :pending, :conditions => ["validated = FALSE AND content IS NULL OR content = ''"]
  named_scope :by_attribute, lambda { |attribute_name| { :conditions => ["translatable_attribute = ?", attribute_name.to_s.downcase] } }
  named_scope :by_type, lambda { |class_name| { :conditions => ["translatable_type = ?", class_name.to_s.downcase] } }
  named_scope :by_language, lambda { |language| { :conditions => ["language = ?", language.to_s] } }
  
  def self.translatable_types
    find(:all).collect{ |t| t.translatable_type }.uniq
  end
  
  def pending_or_dirty?
    !validated
  end
  
  def pending?
    !validated && content.blank?
  end
  
  def dirty?
    !validated && !content.blank?
  end
  
  def validated?
    validated
  end
  
  def set_as_dirty
    @dirty = true
  end
  
  def default_value
    translatable.read_attribute(translatable_attribute)
  end
  
  protected
  
  def validate_translation
    if @dirty
      self.validated = false
    else
      self.validated = content.blank? ? false : true
    end
    return true
  end
end