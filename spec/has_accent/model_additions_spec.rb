require File.dirname(__FILE__) + '/../spec_helper'

describe MockedModel do
  after(:each) do
    MockedModel.reset_columns
  end
  
  it "should be able to add a column" do
    MockedModel.add_column('foo')
    MockedModel.columns.should have(1).record
    MockedModel.columns.first.name.should == 'foo'
  end
end

describe MockedModel, "without has_accent" do
  before(:each) do
    MockedModel.add_column(:name, :string)
    MockedModel.add_column(:description, :text)
    MockedModel.add_column(:price, :float)
    @model = MockedModel.new
  end
  
  after(:each) do
    MockedModel.reset_columns
  end
  
  it "should not respond to the translated_* methods when has_accent hasn't been set in the model" do
    @model.should_not respond_to(:translated_name)
    @model.should_not respond_to(:translated_description)
    @model.should_not respond_to(:translated_price)
  end
end

describe MockedModel, "with has_accent and no parameters" do
  before(:each) do
    HasAccent.default_language = :en
    HasAccent.languages = [:fr, :es]
    MockedModel.add_column(:name, :string)
    MockedModel.add_column(:description, :text)
    MockedModel.add_column(:price, :float)
    MockedModel.has_accent
    @model = MockedModel.new
  end
  
  after(:each) do
    MockedModel.clear_method(:translated_name)
    MockedModel.clear_method(:translated_description)
    MockedModel.reset_columns
  end
  
  it "should only add a translated_column_name method to the model for each string or text column" do
    @model.should respond_to(:translated_name)
    @model.should respond_to(:translated_description)
    @model.should_not respond_to(:translated_price)
  end
  
  it "should only raise an invalid argument error when you try to translate to an invalid language" do
    HasAccent.languages.should eql([:fr, :es])
    lambda { @model.translated_name(:de) }.should raise_error(ArgumentError)
    lambda { @model.translated_description(:cn) }.should raise_error(ArgumentError)
    lambda { @model.translated_name(:es) }.should_not raise_error(ArgumentError)
    lambda { @model.translated_description(:fr) }.should_not raise_error(ArgumentError)
  end
    
end

describe MockedModel, "with has_accent and specifying the column names" do
  before(:each) do
    HasAccent.default_language = :en
    HasAccent.languages = [:fr, :es]
    MockedModel.add_column(:name, :string)
    MockedModel.add_column(:description, :text)
    MockedModel.add_column(:price, :float)
    MockedModel.has_accent(:name)
    @model = MockedModel.new
  end
  
  after(:each) do
    MockedModel.clear_method(:translated_name)
    MockedModel.reset_columns
  end
  
  it "should only add a translated_column_name method for the specifying fields" do
    @model.should respond_to(:translated_name)
    @model.should_not respond_to(:translated_description)
    @model.should_not respond_to(:translated_price)
  end
  
  it "should only raise an invalid argument error when you try to translate to an invalid language" do
    HasAccent.languages.should eql([:fr, :es])
    lambda { @model.translated_name(:de) }.should raise_error(ArgumentError)
    lambda { @model.translated_name(:es) }.should_not raise_error(ArgumentError)
  end
end

describe MockedModel, "with has_accent and specifying non string or text columns" do
  before(:each) do
    MockedModel.add_column(:name, :string)
    MockedModel.add_column(:description, :text)
    MockedModel.add_column(:price, :float)
  end
  
  it "should raise an invalid argument error when you try to set an invalid column type" do
    lambda{ MockedModel.has_accent(:name, :price) }.should raise_error(ArgumentError)
  end
end