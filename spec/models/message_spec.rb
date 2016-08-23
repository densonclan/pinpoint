require 'spec_helper'

describe Message do
  before(:each) do
    @message = FactoryGirl.build(:message)
  end

  it "should have a receiver" do
  	@message.receiver = nil
  	@message.should_not be_valid
  end

  it "should have a sender" do
  	@message.user = nil
  	@message.should_not be_valid
  end

  it "should have a subject line" do
  	@message.subject = nil
  	@message.should_not be_valid

  	@message.subject = ''
  	@message.should_not be_valid
  end

  it "should have a message content" do
  	@message.full_text = nil
  	@message.should_not be_valid

  	@message.full_text = ''
  	@message.should_not be_valid
  end
end
