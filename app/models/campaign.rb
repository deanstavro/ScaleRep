class Campaign < ApplicationRecord
	has_many :leads
	has_many :data_uploads
	belongs_to :client_company
    belongs_to :persona

	# enum
	enum campaign_type: [ :standard, :auto_reply, :direct_referral, :auto_reply_referrall]
	validates :campaign_name, uniqueness: { scope: :client_company }, presence: true
	validates :contactLimit, presence: true
end
