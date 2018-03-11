class ClientCompany < ApplicationRecord
	has_many :users
	has_many :leads

	enum plan: [:data_source, :lead_generate, :qualify, :custom]
end
