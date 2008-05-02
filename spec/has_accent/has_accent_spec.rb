require File.dirname(__FILE__) + '/../spec_helper'

describe HasAccent do
  
  it "should have a default language of english" do
    HasAccent.default_language.should eql(:en)
  end
  
  it "should allow you to change the default language" do
    HasAccent.default_language.should eql(:en)
    HasAccent.default_language = :es
    HasAccent.default_language.should eql(:es)
  end
  
  it "should allow you to change the list of enabled languages" do
    HasAccent.languages = [:fr, :de]
    HasAccent.languages.should eql([:fr, :de])
  end
  
end