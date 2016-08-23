require 'spec_helper'

describe 'distributors/index.html.erb' do


  before do
    assign(:distributors, paginated_collection_of(:distributor))
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
    specify { rendered.should_not match(new_distributor_path) }
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
    specify { rendered.should_not match(new_distributor_path) }
  end

  describe 'as internal user' do
    before do
      controller.singleton_class.class_eval do
        def current_user
          User.new(user_type: User::DISTRIBUTION)
        end
        helper_method :current_user
      end
      render
    end
    specify { rendered.should match(new_distributor_path) }
  end
end