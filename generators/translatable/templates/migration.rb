class CreateTranslations < ActiveRecord::Migration
  def self.up
    create_table :translations do |t|
      t.string :translatable_type, :translatable_attribute, :language
      t.integer :translatable_id
      t.text :content
      t.boolean :validated, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :translations
  end
end
