module LockChecks

  def self.included(base)
    base.class_eval do  
      validate :check_has_lock, on: :update
      after_save :delete_lock
      before_destroy :check_has_lock

      attr_accessor :override_lock

      def check_has_lock
        return true if override_lock
        if lock
          if lock.user != updated_by
            errors.add(:base, "The lock on this store is held by #{lock.user.name}")
            return false
          end
        else
          errors.add(:base, 'This record is not locked')
          return false
        end
        true
      end

      def delete_lock
        lock.destroy if lock
      end
    end
  end
end