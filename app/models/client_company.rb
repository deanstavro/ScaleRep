class ClientCompany < ApplicationRecord
	has_many :users
	has_many :leads
	has_many :client_reports

	validates :name, presence: true
	validates :company_domain, presence: true
end
