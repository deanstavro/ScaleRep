class Template < ApplicationRecord
	belongs_to :client_company

	validates :title, presence: true
	validates :body, presence: true
	validates :client_company, presence: true
	validates :subject, presence: true
	
end
