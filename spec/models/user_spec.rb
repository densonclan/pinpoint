# ./spec/models/user_spec.rb
require 'spec_helper'

describe User do

  describe 'with user' do
    before { @user = User.new(name: 'Bob Doe', email: 'bob@example.com', password: 'bobek32', phone: '+44 692423321', approved: true, client_id: 12, user_type: User::CLIENT, department: FactoryGirl.build(:department)) }
      
    describe 'validations' do
      describe 'valid' do
        specify { @user.should be_valid }
      end
      describe 'missing name' do
        before { @user.name = '' }
        specify { @user.should_not be_valid }
      end
      describe 'missing email' do
        before { @user.email = '' }
        specify { @user.should_not be_valid }
      end
      describe 'missing phone' do
        before { @user.phone = '' }
        specify { @user.should_not be_valid }
      end
      describe 'missing department' do
        before { @user.department = nil }
        specify { @user.should_not be_valid }
      end
      describe 'missing client' do
        before { @user.client = nil }
        describe 'when not internal and approved' do
          specify { @user.should_not be_valid }
        end
        describe 'when internal' do
          before { @user.user_type = User::DISTRIBUTION }
          specify { @user.should be_valid }
        end
        describe 'when not approved' do
          before { @user.approved = false }
          specify { @user.should be_valid }
        end
      end
    end

    describe "activate!" do
      before do
        @user.save
        ActionMailer::Base.deliveries.clear
        @user.activate!
      end
      specify { @user.should be_approved }
      specify { @user.should_not be_new_record }
      specify { ActionMailer::Base.deliveries.length.should == 1 }
      specify { ActionMailer::Base.deliveries.last.subject.should == 'Your Pinpoint account has been activated' }
    end

    describe "deactivate!" do
      before do
        @user.approved = true
        @user.save
        @user.deactivate!
      end
      specify { @user.should_not be_approved }
    end
  end

  describe 'deliver require activation email after signup' do
    before do
      ActionMailer::Base.deliveries.clear
      create_a(:just_user, approved: true)
      User.create(name: 'Bob Doe', email: 'bob@example.com', password: 'bobek32', phone: '+44 692423321', approved: false, user_type: User::READ_ONLY, department: FactoryGirl.build(:department))
    end
    specify { ActionMailer::Base.deliveries.length.should == 1 }
  end

  describe 'all admins' do
    before do
      @admin1 = create_a(:just_user, name: 'Gary', user_type: User::ADMIN)
      @client = create_a(:just_user, name: 'Client', user_type: User::CLIENT)
      @admin2 = create_a(:just_user, name: 'Barry', user_type: User::ADMIN)
      @dist = create_a(:just_user, name: 'Dist', user_type: User::DISTRIBUTION)
    end
    specify { User.all_admins.sort.should == [@admin1, @admin2].sort }
  end
end