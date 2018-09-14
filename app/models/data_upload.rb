class DataUpload < ApplicationRecord
  belongs_to :client_company
  belongs_to :campaign
  #belongs_to :user
  serialize :rules, Array

end
