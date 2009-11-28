require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Merb::GlobalHelpers, "String#truncate" do

  it "should not truncate the string if the string is not longer than the given parameter" do
    [5,10,15].each do |i|
      s = "a" * i
      s.truncate(16).size.should == i
    end
  end

  it "should truncate a string and put '...' on the end" do
    a = "abc def ghi jkl mno pqr"
    a.truncate(15).should == "abc def ghi jkl..."
  end

  it "should truncate a string and put '...' at the closest previous word boundary" do
    a = "abc def ghi jkl mno pqr"
    a.truncate(17).should == "abc def ghi jkl..."
  end

  it "should put a different suffix on it if I want" do
    a = "abc def"
    a.truncate(6, "!!!").should == "abc!!!"
  end

  it "should truncate the string if there are no spaces" do
    a = "abcdefghijk"
    a.truncate(3).should == "abc..."
  end

  it "should not change the string when it truncates" do
    a = "abcdef"
    a.truncate(2)
    a.should == "abcdef"
  end


end
