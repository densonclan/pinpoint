require 'spec_helper'

describe OrderAccessor do

  context '#copy_order_with_id' do
    let(:client) { create_a(:client) }
    let(:store) { create_a(:store, account_number: 'ABC123', client: client) }
    let(:postcode_sector1) { create_a(:postcode_sector) }
    let(:postcode_sector2) { create_a(:postcode_sector) }
    let(:distribution1) { create_a(:distribution, total_quantity: 1001, postcode_sectors: [postcode_sector1, postcode_sector2]) }
    let(:distribution2) { create_a(:distribution, total_quantity: 9999, postcode_sectors: [postcode_sector2]) }
    let(:comment) { create_a(:comment) }
    let(:order) { create_a(:order, store: store, total_price: 4429, status: Order::COMPLETED, distributions: [distribution1, distribution2], comments: [comment]) }
    let(:user) { create_a(:user, client: client) }
    subject { OrderAccessor.new(user).copy_order_with_id(order.id.to_s) }

    it 'should copy the order' do
      subject.should be_new_record
      subject.account_number.should == 'ABC123'
      subject.total_price.should == 4429
      subject.distributions.length.should == 2
      subject.status.should == Order::AWAITING_PRINT
      subject.comments.map(&:full_text).should == [comment.full_text]
      distribution1 = subject.distributions.select {|d| d.total_quantity == 1001 }.first
      distribution2 = subject.distributions.select {|d| d.total_quantity == 9999 }.first
      distribution1.postcode_ids.should == "#{postcode_sector1.id},#{postcode_sector2.id}"
      distribution2.postcode_ids.should == "#{postcode_sector2.id}" #distribution_postcodes.map {|dp| dp.postcode_sector_id}.sort.should == [postcode_sector2.id].sort
    end
  end
end