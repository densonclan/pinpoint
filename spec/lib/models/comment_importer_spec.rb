require 'spec_helper'

describe CommentImporter do

  before do
    @transport = Transport.new
    @transport.user = @user = User.new
    @importer = CommentImporter.new(@transport)
  end

  describe 'model_class' do
    specify { @importer.model_class.should == Comment }
  end

  describe 'field_names' do
    specify { @importer.class.field_names.should == %w(account_number postcode full_text) }
  end

  describe 'set_extra_attributes' do
    before do
      @importer.should_receive(:set_user).with(@comment = Comment.new)
      @importer.should_receive(:set_store).with(@comment, @row = 'data', 9)
    end
    specify { @importer.set_extra_attributes(@comment, @row, 9).should be_nil }
  end

  describe 'set_user' do
    before do
      @user.should_receive(:id).and_return 12
      @user.should_receive(:department).and_return double(id: 15)
      @importer.set_user(@comment = Comment.new)
    end
    specify { @comment.user_id.should == 12 }
    specify { @comment.department_id.should == 15 }
  end

  describe 'set_store' do
    describe 'with account number' do
      describe 'valid' do
        before do
          Store.should_receive(:find_by_account_number).with('xyz').and_return @store = Store.new
          @importer.should_not_receive(:save_error)
          @importer.set_store(@comment = Comment.new, {'account_number' => 'xyz'}, 9)
        end
        specify { @comment.commentable.should == @store }
      end
      describe 'invalid' do
        before do
          Store.should_receive(:find_by_account_number).with('xyz').and_return nil
          @importer.should_receive(:save_error).with(9, "Invalid store account number 'xyz'")
          @importer.set_store(@comment = Comment.new, {'account_number' => 'xyz'}, 9)
        end
        specify { @comment.commentable.should be_nil }
      end
    end
    describe 'with postcode' do
      describe 'valid' do
        before do
          Store.should_receive(:find_by_postcode).with('xyz').and_return @store = Store.new
          @importer.should_not_receive(:save_error)
          @importer.set_store(@comment = Comment.new, {'account_number' => '', 'postcode' => 'xyz'}, 9)
        end
        specify { @comment.commentable.should == @store }
      end
      describe 'invalid' do
        before do
          Store.should_receive(:find_by_postcode).with('xyz').and_return nil
          @importer.should_receive(:save_error).with(9, "Invalid store postcode 'xyz'")
          @importer.set_store(@comment = Comment.new, {'account_number' => '', 'postcode' => 'xyz'}, 9)
        end
        specify { @comment.commentable.should be_nil }
      end
    end
    describe 'without account number or postcode' do
      before do
        @importer.should_receive(:save_error).with(9, "Missing store account number or postcode")
        @importer.set_store(@comment = Comment.new, {'account_number' => '', 'postcode' => ''}, 9)
      end
      specify { @comment.commentable.should be_nil }
    end
  end
end