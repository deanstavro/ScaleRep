class ClientCompany < ApplicationRecord
	has_many :users
	has_many :leads
	has_many :client_reports

	enum plan: [:data_source, :lead_generate, :qualify, :custom]
end
