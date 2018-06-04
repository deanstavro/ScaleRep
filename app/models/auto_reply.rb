class AutoReply < ApplicationRecord
  belongs_to :campaign
  belongs_to :client_company
end
