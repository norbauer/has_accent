module HasAccent
  module Localize 
    def self.included(base) 
      base.extend ModelMethods 
    end
  
    module ModelMethods
      
      def has_accent(*attribute_names)
        
        unless included_modules.include? InstanceMethods 
          extend ClassMethods
          include InstanceMethods
        end
        
        has_many :translations, :as => :translatable, :dependent => :destroy
        after_create :create_pending_translations
        before_save :set_pending_translations
        
        attribute_names = attribute_names.map(&:to_sym)
        begin
          valid_columns = columns.select{ |column| column.type == :string || column.type == :text }.collect{ |column| column.name.to_sym }
          erroneous_columns = attribute_names - valid_columns
        rescue
          valid_columns, erroneous_columns = [], []
        end
        
        unless erroneous_columns.blank?
          raise(ArgumentError, err_the_sentence(erroneous_columns))
        end
        
        options = attribute_names.extract_options!
        attribute_names = valid_columns if attribute_names.empty?
        options[:attribute_names] = attribute_names
        options[:default_language] ||= HasAccent.default_language
        options[:languages] ||= HasAccent.languages
        options[:languages] = options[:languages].map(&:to_sym)
        class_inheritable_accessor :options
        self.options = options
        
        attribute_names.uniq.each do |attribute_name|
          # Define the translated_attribute instance methods
          define_method "translated_#{attribute_name}" do |*args|
            raise(ArgumentError, "wrong number of arguments (#{args.size} for 0 or 1)") if args.size > 1
            lang = args.empty? ? HasAccent.current_language : args.first
            raise(ArgumentError, "invalid language '#{lang}'") unless all_possible_languages.include?(lang.to_sym)
            return read_attribute(attribute_name) if lang.to_sym == options[:default_language].to_sym
            if translation = translations.find_by_translatable_attribute_and_language(attribute_name.to_s, lang.to_s)
              return translation.pending_or_dirty? ? read_attribute(attribute_name) : translation.content
            else
              translations.create(:language => lang.to_s, :translatable_attribute => attribute_name.to_s)
              return read_attribute(attribute_name)
            end
          end
          
          # Define the find_by_translated_attribute class methods
          singleton = (class << self; self end)
          singleton.send(:define_method, "find_by_translated_#{attribute_name}") do |*args|
            raise(ArgumentError, "wrong number of arguments (#{args.size} for 1)") if args.size != 1
            if record = self.send("find_by_#{attribute_name}", args.first.to_s)
              return record
            else
              translation = Translation.find_by_translatable_attribute_and_content(attribute_name.to_s, args.first.to_s)
              return translation ? translation.translatable : nil
            end
          end
        end
      end
    end
  
    module ClassMethods
      def err_the_sentence(erroneous_columns)
        err = String.new
        err << "has_accent attributes must map either to text or string DB columns. "
        err << "#{erroneous_columns.to_sentence.capitalize} #{ erroneous_columns.length > 1 ? "do" : "does"} not."
      end
    end
  
    module InstanceMethods      
      protected
      
      def all_possible_languages
        (options[:languages] << options[:default_language]).map(&:to_sym)
      end
      
      def create_pending_translations
        options[:attribute_names].each do |attribute_name|
          options[:languages].each do |language|
            possible_translation = nil
            if similar_records = self.class.find(:all, :conditions => ["#{attribute_name} = ? AND id != ?", self.read_attribute(attribute_name), self.read_attribute(:id)])
              similar_records.each do |similar_record|
                possible_translation = similar_record.translations.validated.by_language(language).first
                break if possible_translation
              end
            end
            translation = self.translations.create(:translatable_attribute => attribute_name.to_s, :language => language.to_s)
            translation.content = possible_translation ? possible_translation.content : nil
            translation.set_as_dirty if possible_translation
            translation.save
          end
        end
      end
      
      def set_pending_translations
        changed.each do |attribute_name|
          for translation in translations.find(:all, :conditions => { :translatable_attribute => attribute_name })
            translation.set_as_dirty
            translation.save
          end
        end
      end
    end
  end
end