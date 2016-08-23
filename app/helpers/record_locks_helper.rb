module RecordLocksHelper

  def form_lock_class(obj)
    obj.nil? || obj.new_record? ? nil : i_have_lock?(obj) ? 'has-lock' : ' no-lock'
  end

  def i_have_lock?(obj)
    obj.nil? || obj.new_record? || (obj.lock && obj.lock.user == current_user)
  end
end