class Persona < ApplicationRecord
  has_many :campaigns
  belongs_to :client_company
  validates :name, presence: true

end
