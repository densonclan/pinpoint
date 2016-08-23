require 'spec_helper'

describe OrderDestroyer do

  let(:client) { create_a(:client) }
  let(:user) { create_a(:user, client: client, user_type: User::CLIENT) }
  let(:store) { create_a(:store, client: client) }
  let(:order) { create_a(:order, store: store) }
  let(:destroyer) { OrderDestroyer.new(user, order.id.to_s) }

  context '#perform' do
    describe 'without permission' do
      let(:user) { create_a(:user, user_type: User::CLIENT) }
      before { order.lock!(user) }
      it 'should raise exception' do
        expect { destroyer.perform }.to raise_error
        Order.count.should == 1
      end
    end
    describe 'without lock' do
      subject { destroyer.perform }
      it { should_not be_destroyed }
    end
    describe 'with lock' do
      subject { destroyer.perform }
      before { order.lock!(user) }
      it 'should return nil' do
        subject.should be_destroyed
        Order.count.should == 0
      end
    end
  end
end