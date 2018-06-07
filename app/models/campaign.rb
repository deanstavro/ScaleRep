class Campaign < ApplicationRecord
	has_many :leads
	belongs_to :client_company
    belongs_to :persona

	# enum
	enum campaign_type: [ :standard, :auto_reply, :direct_referral, :auto_reply_referrall]
end
