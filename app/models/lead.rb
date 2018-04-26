class Lead < ApplicationRecord
	belongs_to :client_company, optional: false
	belongs_to :campaign, optional: true

	after_initialize :init

	validates :email, presence: true
	validates :client_company, presence: true
	validates_uniqueness_of :email, scope: :client_company
	
	validates :first_name, presence: true
	validates :last_name, presence: true
	



    def init
      self.contract_amount ||= 0           #will set the default value only if it's nil
      self.contract_sent ||= :no


    end

end
