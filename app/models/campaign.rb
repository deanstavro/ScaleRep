class Campaign < ApplicationRecord
	has_many :leads
	belongs_to :client_company
end
