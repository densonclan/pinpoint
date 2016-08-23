class Document < ActiveRecord::Base
  has_paper_trail

  belongs_to :user
  belongs_to :store

  before_validation :set_store_from_account
  validates_presence_of :title, :store
  validates_length_of :description, :maximum => 400, :allow_blank => true
  validates_attachment :file, :presence => true

  has_attached_file :file
  attr_accessible :description, :file, :title, :document_type, :store_id, :account_number
  attr_accessor :account_number

  scope :ordered, order(:id) # for now
  scope :accessible_by, lambda {|user| user.internal? ? where('1=1') : joins(:user).where('users.client_id=?', user.client_id)}

  def self.new_with_user(params, user)
    document = Document.new(params)
    document.user = user
    document
  end

  def self.search(query)
    joins(:store).where('stores.owner_name ILIKE ? OR stores.account_number ILIKE ? OR documents.title ILIKE ? OR documents.description ILIKE ?', "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")
  end

  #
  # Export the model's data to CSV
  #
  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |subject|
        csv << subject.attributes.values_at(*column_names)
      end
    end
  end

  private

  def set_store_from_account
    self.store = Store.find_by_account_number account_number if account_number && !store
  end
end