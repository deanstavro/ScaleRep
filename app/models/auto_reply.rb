class AutoReply < ApplicationRecord
  belongs_to :campaign, optional: true
  belongs_to :client_company, optional: true
end
