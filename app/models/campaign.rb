class Campaign < ApplicationRecord
	has_many :leads
	has_many :auto_replies
	belongs_to :client_company
  belongs_to :persona

	# enum
	enum campaign_type: [ :standard, :auto_reply, :direct_referral, :auto_reply_referral ]
end
