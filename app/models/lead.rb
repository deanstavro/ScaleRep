class Lead < ApplicationRecord
	require 'csv'

	belongs_to :client_company, optional: false
	belongs_to :campaign, optional: true

	after_initialize :init

	validates :email, presence: true
	validates :client_company, presence: true
	validates_uniqueness_of :email, scope: :client_company
	
	validates :first_name, presence: true
	validates :last_name, presence: true



	


	def self.import(file, company, leads)
		not_imported = 0
		duplicates = 0

		CSV.foreach(file.path, headers: true) do |row|
			one_hash = row.to_hash

			puts one_hash
			email = one_hash["email"]

			begin
				if leads.where(:email => email).count == 0
					puts "NO"
					one_hash[:client_company] = company
					lead = Lead.create!(one_hash)
				else
					puts "HI"
					duplicates = duplicates + 1 
				end
			rescue Exception => e
				not_imported = not_imported + 1
			end		

			
		

		

		end
		return duplicates.to_s + " duplicates ignored, " + not_imported.to_s + " contacts not imported due to error. Check column names."
	end

    def init
      self.contract_amount ||= 0           #will set the default value only if it's nil
      self.contract_sent ||= :no
    end

end
