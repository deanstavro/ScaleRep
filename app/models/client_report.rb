class ClientReport < ApplicationRecord
	belongs_to :client_company, optional: true
end
