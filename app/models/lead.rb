class Lead < ApplicationRecord
	belongs_to :client_company, optional: false
	belongs_to :campaign, optional: true

	enum contract_sent: [:yes, :no]
	after_initialize :init

	validates :potential_deal_size, presence: true
	validates :date_sourced, presence: true



    def init
      self.contract_amount ||= 0           #will set the default value only if it's nil
      self.contract_sent ||= :no
    end

end
