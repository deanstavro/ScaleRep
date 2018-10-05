class LeadAction < ApplicationRecord
  belongs_to :touchpoint
  belongs_to :lead
  belongs_to :client_company

  enum action: [:open, :reply, :opt_out, :bounce]
end
