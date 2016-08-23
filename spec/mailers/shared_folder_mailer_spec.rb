require "spec_helper"

describe SharedFolderMailer do
  describe 'notify' do
    before do
      user = FactoryGirl.create(:user, name: 'Jonno', email: 'jonathon@arctickiwi.com')
      owner = FactoryGirl.create(:user, name: 'Jini', email: 'jini@arctickiwi.com')
      shared_folder = SharedFolder.create(user_id: user.id, folder_id: Folder.create(name: 'name', user: owner).id)
      @email = SharedFolderMailer.notify(shared_folder)
    end
    specify { @email.subject.should == "You have a new folder shared by Jini" }
  end
end