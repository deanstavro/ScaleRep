class User < ApplicationRecord
  
  belongs_to :client_company, optional: true
  has_many :data_uploads
  enum role: [:user, :scalerep]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  validates :client_company, presence: true

  # Set user to default user or what's selected
  after_initialize :set_default_role, :if => :new_record?
  
  # Generate API key after user creation
  after_create :generate_key

  
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
