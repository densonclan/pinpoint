require 'spec_helper'

describe FoldersController do
  let(:user) { FactoryGirl.create(:user) }
  let(:folder) { FactoryGirl.create(:folder, user: user) }
  let(:other_folder) { FactoryGirl.create(:folder, user: FactoryGirl.create(:user)) }

  before do
    @controller.should_receive(:authenticate_user!)
    @controller.should_receive(:current_user).at_least(:once).and_return(user)
  end

  describe 'index' do
    it 'should render index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'create' do
    it 'should create folder' do
      post :create, folder: { name: 'name' }
      expect(response).to redirect_to(action: :index)
    end

    it 'should create folder inside another folder' do
      post :create, folder: { name: 'name', parent_id: folder.id }
      expect(response).to redirect_to(action: :browse, id: folder.reload.children.first.id)
    end
  end

  describe 'browse' do
    it 'should render index template' do
      get :browse, id: folder.id
      expect(response).to render_template(:index)
    end
  end

  describe 'destroy' do
    it 'should delete the folder' do
      delete :destroy, id: folder.id
      expect(response).to redirect_to(folders_path)
    end
  end
end