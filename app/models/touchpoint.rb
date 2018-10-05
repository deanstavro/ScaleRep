class Touchpoint < ApplicationRecord
  belongs_to :lead
  belongs_to :campaign
  belongs_to :client_company

  has_many :lead_actions

  enum channel: [:email, :voicemail]


end
