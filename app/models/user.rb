class User < ApplicationRecord
  
  belongs_to :client_company, optional: true
  enum role: [:user, :scalerep, :admin]
  after_initialize :set_default_role, :if => :new_record?
  after_create :generate_key

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  validates :client_company, presence: true

  def set_default_role
    self.role ||= :user
  end

  def generate_key
    begin
      self.api_key = SecureRandom.hex
    end while self.class.exists?(api_key: api_key)
    self.save!
  end

  

end
