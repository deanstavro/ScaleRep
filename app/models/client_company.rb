class ClientCompany < ApplicationRecord
	has_many :users
	has_many :leads
	has_many :campaigns
	has_many :personas
	has_many :campaign_replies
	has_many :accounts
	has_many :data_uploads
	has_many :touchpoints
	has_many :lead_actions
	has_one :salesforce

	validates :name, presence: true, uniqueness: true
	validates :company_domain, presence: true
	validates :account_manager, presence: true
	validates :monthlyContactEngagementCount, presence: true
	validates :monthlyContactProspectingCount, presence: true

	# JSON Serialized Column
	serialize :replyio_keys
	# Allows us to call @company.campaign.build
	attr_accessor :campaign_id
	after_create :generate_key


	

	def generate_key
	    begin
	      self.api_key = SecureRandom.hex
	    end while self.class.exists?(api_key: api_key)
	    self.save!
  	end
end
