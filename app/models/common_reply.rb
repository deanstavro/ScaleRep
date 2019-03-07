class CommonReply < ApplicationRecord
	belongs_to :client_company

	validates :name, presence: true
    validates :common_message, presence: true
    validates :reply_message, presence: true
    validates :client_company, presence: true
end