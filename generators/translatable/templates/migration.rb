class CreateTranslations < ActiveRecord::Migration
  def self.up
    create_table :translations do |t|
      t.string :translatable_attribute, :language
      t.references :translatable, :polymorphic => true
      t.text :content
      t.boolean :validated, :default => false
      t.timestampst
    end
  end

  def self.down
    drop_table :translations
  end
end
