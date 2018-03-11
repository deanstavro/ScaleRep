class ClientCompany < ApplicationRecord
	has_many :users

	enum plan: [:data_source, :lead_generate, :qualify, :custom]
end
