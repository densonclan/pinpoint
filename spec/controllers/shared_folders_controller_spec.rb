require 'spec_helper'

describe SharedFoldersController do
  let(:user) { FactoryGirl.create(:user) }
  let(:folder) { FactoryGirl.create(:folder, user: user) }
  let(:other_folder) { FactoryGirl.create(:folder, user: FactoryGirl.create(:user)) }

  before do
    @controller.should_receive(:authenticate_user!)
    @controller.should_receive(:current_user).at_least(:once).and_return(user)
  end

  describe 'index' do
    it 'should send shared data as json for a folder' do
      get :index, folder_id: folder.id
      response.should be_success
    end

    it 'should return 404 if user tries to access other folder' do
      get :index, folder_id: other_folder.id
      response.should be_not_found
    end
  end

  describe 'create' do
    it 'should share folder to user' do
      new_user = FactoryGirl.create(:user)
      post :create, folder_id: folder.id, users: [new_user.id.to_s]

      response.should be_success
      expect(new_user.reload.shared_folders.count).to eq(1)
    end

    it 'should share folder to user' do
      new_user = FactoryGirl.create(:user)
      new1 = FactoryGirl.create(:user)
      SharedFolder.create(folder_id: folder.id, user_id: new1.id)
      post :create, folder_id: folder.id, users: [new_user.id.to_s]

      response.should be_success
      expect(new_user.reload.shared_folders.count).to eq(1)
      expect(new1.reload.shared_folders.count).to eq(0)
    end

    it 'should not allow to share folder of other users' do
      new_user = FactoryGirl.create(:user)
      post :create, folder_id: other_folder.id, users: [new_user.id.to_s]

      response.should be_not_found
      expect(new_user.reload.shared_folders.count).to eq(0)
    end
  end
end