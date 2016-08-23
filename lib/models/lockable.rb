module Lockable

  def lock!(user)
    unless lock
      self.updated_by = user
      self.lock = RecordLock.create user: user, record: self
    end
  end

  def self.included(base)
    base.class_eval do  
      has_one :lock, class_name: 'RecordLock', as: :record
    end
  end
end