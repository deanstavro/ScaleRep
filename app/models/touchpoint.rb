class Touchpoint < ApplicationRecord
  belongs_to :lead
  belongs_to :campaign
  belongs_to :client_company

  enum channel: [:email, :voicemail]


end
