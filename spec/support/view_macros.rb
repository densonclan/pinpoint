module ViewHelpers

  def read_only_user
    controller.singleton_class.class_eval do
      def current_user
        User.new(user_type: User::READ_ONLY)
      end
      helper_method :current_user
    end
  end

  def client_user
    controller.singleton_class.class_eval do
      def current_user
        User.new(user_type: User::CLIENT)
      end
      helper_method :current_user
    end
  end
end