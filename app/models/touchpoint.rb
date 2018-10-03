class Touchpoint < ApplicationRecord
  belongs_to :lead
  belongs_to :campaign

  enum channel: [:email, :voicemail]


end
