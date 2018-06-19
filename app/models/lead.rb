class Lead < ApplicationRecord
	require 'csv'
	require 'rest-client'

	belongs_to :client_company, optional: true
	belongs_to :account, optional: true
	has_many :campaign_replies
	#validates :client_company, presence: true

	belongs_to :campaign, optional: true
	enum status: [:cold, :in_campaign, :not_interested, :blacklist, :interested, :meeting_set]
	#validates :email, presence: true
	
	validates_uniqueness_of :email, scope: :client_company
	validates :email, presence: true
	validates :first_name, presence: true
	#validates :last_name, presence: true
	after_initialize :init


	def self.import_to_campaign(file, company, leads, campaign_id, column_names)
		
		puts "Starting importing to campaign"
		not_imported = 0
		duplicates = []
		imported = 0
		rows_email_not_present = 0
		
		#Hash of all rows that will be inputted to reply
		all_hash = []

		CSV.foreach(file.path, headers: true) do |row|
			puts "looping through each row"

			#Take row, convert keys to lowercase, put in key,value hash
  			new_hash = {}
  			row.to_hash.each_pair do |k,v|
 	  			new_hash.merge!({k.downcase => v})
 	  			new_hash.keep_if {|k,_| column_names.include? k }
  			end


			one_hash = new_hash.to_hash
			# If e-mail field is included
			if one_hash["email"].present?

					puts one_hash
					

					email = one_hash["email"]

					begin
						# check for duplicates
						if leads.where(:email => email).count == 0

							one_hash[:client_company] = company
							one_hash[:campaign_id] = campaign_id

							#This is where the account will get updated

							lead = Lead.create!(one_hash)
							all_hash << one_hash

							imported = imported + 1
						else

							duplicates << $.
						end
					rescue Exception => e
						not_imported = not_imported + 1
					end
			else
				rows_email_not_present = rows_email_not_present + 1
			end


		end
		AddContactsToReplyJob.perform_later(all_hash,campaign_id)

		return imported.to_s + " leads imported successfully, duplicate lead rows not uploaded: "+ duplicates.to_s + ", " + rows_email_not_present.to_s + " rows without email field"
	end

	private


	def one_hash
		one_hash.require(:lead).permit(:decision_maker, :internal_notes, :email_in_contact_with, :date_sourced, :client_company, :campaign_id, :contract_sent, :contract_amount, :timeline, :project_scope, :email_handed_off_too, :meeting_time, :email, :first_name, :last_name, :hunter_score, :hunter_date, :title, :phone_type, :phone_number, :city, :state, :country, :linkedin, :timezone, :address, :meeting_taken, :full_name, :status, :company_name, :company_website, :account_id)
		# 
		#id, decision_maker, internal_notes, email_in_contact_with, date_sourced
    	# created_at, updated_at, client_company_id, campaign_id, contract_sent,
    	# contract_amount, timeline, project_scope, email_handed_off_too, meeting_time,
    	# email, first_name, last_name, hunter_score, hunter_date, title, phone_type,
    	# phone_number, city, state, country, linkedin, timezone, address, meeting_taken,
    	# full_name, status, company_name, company_website, account_id
	end





    def init
      self.contract_amount ||= 0           #will set the default value only if it's nil
      self.contract_sent ||= :no
    end



end
