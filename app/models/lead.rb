class Lead < ApplicationRecord
	belongs_to :client_company, optional: true
	belongs_to :campaign, optional: true
end
