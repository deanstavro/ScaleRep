class DataUpload < ApplicationRecord
  belongs_to :client_company
  belongs_to :campaign

end
