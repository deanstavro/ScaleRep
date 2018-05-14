class Campaign < ApplicationRecord
	has_many :leads
	belongs_to :client_company
  belongs_to :persona
end
