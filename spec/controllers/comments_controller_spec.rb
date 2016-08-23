require 'spec_helper'

describe CommentsController do
  before do
    @controller.should_receive(:authenticate_user!)
    @controller.stub(:update_last_request_stats)
    @controller.stub(:current_user).and_return(@current_user = User.new)
  end

  describe "index" do
    before do
      Comment.should_receive(:accessible_by).with(@current_user).and_return @comments = double
      @comments.should_receive(:for_listing).and_return @comments
      @comments.should_receive(:page).with('2').and_return @comments
      get :index, page: 2
    end
    specify { response.should render_template(:index) }
    specify { assigns[:comments].should == @comments }
  end

  describe 'show' do
    before do
      Comment.should_receive(:accessible_by).with(@current_user).and_return @comment = double
      @comment.should_receive(:find).with('5').and_return(@comment = Comment.new)
      get :show, id: 5
    end
    specify { response.should render_template(:show) }
    specify { assigns[:comment].should == @comment }
  end

  describe 'requiring write access' do
    before { @controller.should_receive(:require_write_access) }

    describe 'new' do
      before do
        get :new, id: 245, type: 'order'
      end
      specify { response.should render_template(:new) }
      specify { assigns[:comment].attributes.should == Comment.new(commentable_type: 'order', commentable_id: 245).attributes }
    end

    describe 'edit' do
      before do
        Comment.should_receive(:accessible_by).with(@current_user).and_return @comment = double
        @comment.should_receive(:find).with('5').and_return(@comment = Comment.new)
        get :edit, id: 5
      end
      specify { response.should render_template(:edit) }
      specify { assigns[:comment].should == @comment }
    end

    describe 'update' do
      before do
        Comment.should_receive(:accessible_by).with(@current_user).and_return @comment = Comment.new(commentable_type: 'Store', commentable_id: 12)
        @comment.should_receive(:find).with('5').and_return @comment
      end
      describe 'successfully' do
        before do
          @comment.should_receive(:update_attributes).with(@params = 'xyz').and_return(true)
          post :update, id: 5, comment: @params
        end
        specify { response.should redirect_to(notes_store_path(12)) }
        specify { flash[:notice].should == 'Changes have been saved.' }
      end

      describe 'unsuccessfully' do
        before do
          @comment.should_receive(:update_attributes).with(@params = 'xyz').and_return(false)
          post :update, id: 5, comment: @params
        end
        specify { response.should render_template(:edit) }
        specify { flash[:error].should == 'Could not save changes.' }
      end
    end

    describe 'destroy' do
      before do
        Comment.should_receive(:accessible_by).with(@current_user).and_return comment = Comment.new(commentable_type: 'Store', commentable_id: 12)
        comment.should_receive(:find).with('5').and_return comment
        comment.should_receive(:destroy)
        post :destroy, id: 5
      end
      specify { response.should redirect_to(notes_store_path(12)) }
      specify { flash[:notice].should == 'Comment has been deleted.' }
    end

    describe "create" do
      before { Comment.should_receive(:new_from_user).with(@params = 'xyz', @current_user).and_return @comment = Comment.new(commentable_type: 'Store', commentable_id: 12) }
      describe "successfully" do
        before do
          @comment.should_receive(:save).and_return(true)
          post :create, comment: 'xyz'
        end
        specify { response.should redirect_to(notes_store_path(12)) }
        specify { flash[:notice].should == 'Comment has been added.' }
      end
      describe "unsuccessfully" do
        before do
          @comment.should_receive(:save).and_return(false)
          post :create, comment: 'xyz'
        end
        specify { response.should render_template(:new) }
        specify { flash[:error].should == 'Could not save the comment.' }
      end
    end
  end
end