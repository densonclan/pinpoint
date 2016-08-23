require 'spec_helper'

describe MessagesController do
  before(:each) do
    signed_in_as_a_valid_user
  end

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end
  end

  describe "GET 'sent'" do
    it "returns http success" do
      get 'sent'
      response.should be_success
    end
  end


  describe "GET 'archived'" do
    it "returns http success" do
      get 'archived'
      response.should be_success
    end
  end

end
