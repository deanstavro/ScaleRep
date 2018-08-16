class AddBlacklistJob < ApplicationJob
	queue_as :default
	
	require 'csv'
	require 'rest-client'

	def perform(file, company, leads, params, col)
		#Take row, convert keys to lowercase, put in key,value hash
		rows_email_not_present = 0
		not_imported = 0
		imported = 0
		duplicates = 0
  		

		#Iterate through file
		CSV.foreach(file.path, headers: true) do |row|

			#Take row, convert keys to lowercase, put in key,value hash
			new_hash = {}
  			row.to_hash.each_pair do |k,v|
 	  			new_hash.merge!({k.downcase => v})
 	  			new_hash.keep_if {|k,_| Lead.column_names.include? k }
  			end

  			one_hash = new_hash.to_hash
			# If e-mail field is included
			if one_hash["email"].present?
				email = one_hash["email"]

				puts one_hash

				#If e-mail does not exist in database
				begin

					# check for duplicates
					if leads.where(:email => email).count == 0
						puts "email is not duplicate"
						lead = Lead.create!(one_hash)
						event = CampaignReply.create!(one_hash)


						#event.update_attributes(:status => "blacklist", :client_company => company, :lead => lead)
						lead.update_attributes(:status => "blacklist", :client_company => company)

					else
						event = CampaignReply.create!(one_hash)
						lead = leads.find_by(email: email)

						event.update_attributes(:client_company_id => company.id, :lead_id => lead.id, :status => "blacklist" )
						#event.update_attributes(:status => "blacklist")
						lead.update_attributes(:status => "blacklist", :client_company => company)
						puts "This is a duplicate. Get the lead and change it to blacklist"
						duplicates = duplicates + 1
					end

					imported = imported + 1

				rescue Exception => e
					not_imported = not_imported + 1
				end
			else
				rows_email_not_present = rows_email_not_present + 1

			end




		#Add it to the company and move it to blacklist as status

		#If email exists, move status to blacklist

		end


		puts imported.to_s + " leads imported successfully to blacklist, duplicate lead rows moved to blacklist: "+ duplicates.to_s + ", " + rows_email_not_present.to_s + " rows without email field, not imported: " + not_imported.to_s

	end

end