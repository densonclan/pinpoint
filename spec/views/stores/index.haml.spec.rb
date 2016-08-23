require 'spec_helper'

describe 'stores/index.haml' do

  before do
    assign(:stores, paginated_collection_of(:just_store, 3))

    controller.singleton_class.class_eval do
      def sort_column
        'account_number'
      end
      def sort_direction
        'asc'
      end
      helper_method :sort_column, :sort_direction
    end
  end


  describe 'as read only user' do
    before do
      controller.singleton_class.class_eval do
        def current_user
          User.new(user_type: User::READ_ONLY)
        end
        helper_method :current_user
      end
      render
    end
    specify { rendered.should_not match(new_store_path) }
  end

  describe 'as client user' do
    before do
      controller.singleton_class.class_eval do
        def current_user
          User.new(user_type: User::CLIENT)
        end
        helper_method :current_user
      end
      render
    end
    specify { rendered.should match(new_store_path) }
  end
end
