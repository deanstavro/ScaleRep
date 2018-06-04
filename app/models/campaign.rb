class Campaign < ApplicationRecord
	has_many :leads
	has_many :auto_replies
	belongs_to :client_company
  belongs_to :persona
end
