class UpdateBlacklistToReplyJob < ApplicationJob
	queue_as :default
	include Reply

	# Loops through leads and deletes them from reply
	def perform(lead_ids)
		for lead_id in lead_ids
			lead = getLead(lead_id)
			company_reply_key = lead.campaign.reply_key
			message = remove_contact_from_reply_by_email(lead.email, company_reply_key)
		end	
	end

	private

	def getLead(leadid)
		return Lead.find_by(id: leadid)
	end

end