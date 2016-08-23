require 'spec_helper'

describe UploadedFilesController do
  let(:user) { FactoryGirl.create(:user) }
  let(:folder) { FactoryGirl.create(:folder, user: user) }
  let(:other_folder) { FactoryGirl.create(:folder, user: FactoryGirl.create(:user)) }

  before do
    @controller.should_receive(:authenticate_user!)
    @controller.should_receive(:current_user).at_least(:once).and_return(user)
  end

  describe 'create' do
    it 'should upload file in given folder' do
      post :create, folder_id: folder.id, file: Rack::Test::UploadedFile.new(Rails.root.to_s + "/spec/files/map.png", "image/png")

      expect(response).to be_success
    end

    it 'should not upload file folder for which user doenst have access to' do
      post :create, folder_id: other_folder.id, file: Rack::Test::UploadedFile.new(Rails.root.to_s + "/spec/files/map.png", "image/png")

      expect(response).to_not be_success
    end
  end

  describe 'destroy' do
    let(:file) { UploadedFile.create(folder_id: folder.id) }
    let(:other_file) { UploadedFile.create(folder_id: other_folder.id) }

    it 'should destroy file' do
      delete :destroy, id: file.id, folder_id: folder.id

      expect(response).to redirect_to(folders_path)
    end

    it 'should not be allowed destroy file belonging to other user\'s' do
      delete :destroy, id: other_file.id, folder_id: other_folder.id

      expect(response).to_not redirect_to(folders_path)
    end
  end

end