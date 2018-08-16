class CampaignReply < ApplicationRecord
	belongs_to :lead, optional: true
  	belongs_to :client_company, optional: true

  	enum status: [:not_interested, :do_not_contact, :opt_out, :interested, :auto_reply, :referral, :auto_reply_referral, :handed_off, :handed_off_with_questions, :sent_meeting_invite, :blacklist]
	validates :email, presence: true

end
