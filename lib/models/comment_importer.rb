class CommentImporter < Importer

  def model_class
    Comment
  end

  def self.field_names
    %w(account_number postcode full_text)
  end

  def set_extra_attributes(comment, row, i)
    set_user(comment)
    set_store(comment, row, i)
  end

  def set_user(comment)
    comment.user_id = @user.id
    comment.department_id = @user.department.id
  end

  def set_store(comment, row, i)
    if !row['account_number'].blank?
      comment.commentable = Store.find_by_account_number row['account_number']
      save_error i, "Invalid store account number '#{row['account_number']}'" if comment.commentable.nil?
    elsif !row['postcode'].blank?
      comment.commentable = Store.find_by_postcode row['postcode']
      save_error i, "Invalid store postcode '#{row['postcode']}'" if comment.commentable.nil?
    else
      save_error i, "Missing store account number or postcode"
    end
  end
end