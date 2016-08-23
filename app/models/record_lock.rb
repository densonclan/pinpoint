class RecordLock < ActiveRecord::Base
  belongs_to :record, polymorphic: true
  belongs_to :user

  validates_uniqueness_of :record_id, scope: :record_type
  validates_format_of :record_type, with: /Store|Order/
  validates_presence_of :user_id, :record_id
end