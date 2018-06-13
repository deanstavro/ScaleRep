class ClientCompany < ApplicationRecord
	has_many :users
	has_many :leads
	has_many :client_reports
	has_many :campaigns
	has_many :personas
	has_many :campaign_replies
	has_many :accounts


	validates :name, presence: true
	validates :company_domain, presence: true
	validates :account_manager, presence: true

	serialize :airtable_keys
	serialize :replyio_keys

	after_create :generate_key

	attr_accessor :campaign_id

	def generate_key
    begin
      self.api_key = SecureRandom.hex
    end while self.class.exists?(api_key: api_key)
    self.save!
  end
end
