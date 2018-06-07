class Lead < ApplicationRecord
	require 'csv'
	require 'rest-client'

	belongs_to :client_company, optional: false
	#validates :client_company, presence: true

	belongs_to :campaign, optional: true
	enum status: [:not_interested, :do_not_contact, :opt_out, :interested, :auto_reply, :referral, :auto_reply_referral]
	#validates :email, presence: true
	
	#validates_uniqueness_of :email, scope: :client_company
	#validates :first_name, presence: true
	#validates :last_name, presence: true
	after_initialize :init



	

	def self.import_to_campaign(file, company, leads, campaign, column_names)
		puts "WE HERE"
		not_imported = 0
		duplicates = 0
		imported = 0
		rows_email_not_present = 0
		all_hash = []


		#ignore cases for fields

		CSV.foreach(file.path, headers: true) do |row|
			puts "GOING THROUGH EACH ROW"


  			new_hash = {}
  			row.to_hash.each_pair do |k,v|
 	  			new_hash.merge!({k.downcase => v})
 	  			new_hash.keep_if {|k,_| column_names.include? k }
  			end

			one_hash = new_hash.to_hash

			if one_hash["email"].present?



					all_hash << one_hash

					email = one_hash["email"]

					begin
						if leads.where(:email => email).count == 0

							one_hash[:client_company] = company
							one_hash[:campaign_id] = campaign

							lead = Lead.create!(one_hash)

							imported = imported + 1
						else

							duplicates = duplicates + 1
						end
					rescue Exception => e
						not_imported = not_imported + 1
					end
			else
				rows_email_not_present = rows_email_not_present + 1
			end


		AddContactsToReplyJob.perform_later(all_hash,campaign)

		end

		return imported.to_s + " imported successfully, "+ duplicates.to_s + " duplicates, " + not_imported.to_s + " contacts not imported, " + rows_email_not_present.to_s + " rows with email not present"
	end

	private


	def one_hash
		one_hash.require(:lead).permit(:company, :industry, :email, :company_domain, :first_name, :last_name, :hunter_score, :hunter_date, :title, :phone_type, :phone_number, :city, :state, :country, :linkedin, :client_company, :campaign_id, :timezone, :address, :company_description, :number_of_employees, :last_funding_type, :last_funding_date, :last_funding_amount, :email_snippet)

	end





    def init
      self.contract_amount ||= 0           #will set the default value only if it's nil
      self.contract_sent ||= :no
    end



end
