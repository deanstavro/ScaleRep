class Lead < ApplicationRecord
	require 'csv'
	require 'rest-client'

	belongs_to :client_company, optional: false
	belongs_to :campaign, optional: true

	

	validates :email, presence: true
	validates :client_company, presence: true
	validates_uniqueness_of :email, scope: :client_company
	validates :first_name, presence: true
	validates :last_name, presence: true

	after_initialize :init




	


	def self.import(file, company, leads)
		not_imported = 0
		duplicates = 0
		imported = 0
		all_hash = []

		CSV.foreach(file.path, headers: true) do |row|
			one_hash = row.to_hash

			all_hash << one_hash

			email = one_hash["email"]
			begin
				if leads.where(:email => email).count == 0

					one_hash[:client_company] = company
					lead = Lead.create!(one_hash)
					imported = imported + 1


				else

					duplicates = duplicates + 1 
				end
			rescue Exception => e
				not_imported = not_imported + 1
			end		

		puts all_hash

		AddContactsToReplyJob.perform_later(all_hash,company.replyio_keys)


		end

		return imported.to_s + " imported successfully, "+ duplicates.to_s + " duplicates, " + not_imported.to_s + " contacts not imported"
	end




    def init
      self.contract_amount ||= 0           #will set the default value only if it's nil
      self.contract_sent ||= :no
    end



end
