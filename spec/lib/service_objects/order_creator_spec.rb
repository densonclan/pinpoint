require 'spec_helper'

describe OrderCreator do

  let(:client) { create_a(:client) }
  let(:option) { create_a(:option, client: client) }
  let(:period) { create_a(:period, client: client) }
  let(:postcode1) { create_a(:postcode_sector) }
  let(:postcode2) { create_a(:postcode_sector) }
  let!(:store) { create_a(:store, account_number: 'S69100', client: client) }
  let(:attributes) { {"account_number"=>"S69100", 
                      "option_id"=>option.id.to_s,
                      "total_price"=>"7500",
                      "period_id"=>period.id.to_s,
                      "distributions_attributes"=>{
                        "0"=>{
                          "distributor_id"=>"4",
                          "total_quantity"=>"4500",
                          "contract_number"=>"12",
                          "reference_number"=>"",
                          "notes"=>"",
                          "distribution_week"=>"-1",
                          "ship_via"=>"NEP",
                          "postcode_ids"=>"#{postcode1},#{postcode2}",
                          "_destroy"=>"false"},
                        "1"=>{
                          "distributor_id"=>"3",
                          "total_quantity"=>"1600",
                          "contract_number"=>"",
                          "reference_number"=>"",
                          "notes"=>"", 
                          "distribution_week"=>"0", 
                          "ship_via"=>"STORE", 
                          "postcode_ids"=>"", 
                          "_destroy"=>"false"},
                        "2"=>{
                          "distributor_id"=>"", 
                          "total_quantity"=>"", 
                          "contract_number"=>"", 
                          "reference_number"=>"", 
                          "notes"=>"", 
                          "distribution_week"=>"", 
                          "ship_via"=>"STORE", 
                          "postcode_ids"=>"", 
                          "_destroy"=>"false"},
                        },
                        "comments_attributes"=>{"0"=>{"full_text"=>"Here's a comment about this order"}}
                      }
                    }

  let(:user) { create_a(:user, client: client) }
  let(:creator) { OrderCreator.new(user, attributes) }
  
  context '#perform' do
    subject { creator.perform }
    it 'should save the order' do
      subject.should be_persisted
      subject.store.should == store
      subject.total_price.should == 7500
      subject.option_id.should == option.id
      subject.period_id.should == period.id
      subject.user.should == user
      subject.updated_by.should == user
      subject.comments.length.should == 1
      subject.comments.first.user.should == user
      subject.comments.first.full_text.should == "Here's a comment about this order"
      subject.total_quantity.should == 6100
    end
  end
end