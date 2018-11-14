class Campaign < ApplicationRecord
	has_many :leads
	has_many :data_uploads
	has_many :touchpoints
	
	belongs_to :client_company
    belongs_to :persona

	# enum
	enum campaign_type: [ :standard, :auto_reply, :direct_referral, :auto_reply_referrall]
	validates :campaign_name, uniqueness: { scope: :client_company }, presence: true

	before_save :default_campaign_metrics


    def default_campaign_metrics
        self.peopleCount ||= 0
        self.deliveriesCount ||= 0
        self.bouncesCount ||= 0
        self.opensCount ||= 0
        self.uniqueOpens ||= 0
        self.optOutsCount ||= 0
        self.outOfOfficeCount ||= 0
        self.repliesCount ||= 0
        self.uniquePeopleContacted ||= 0
        self.campaign_end ||= Date.today + 30.days
        self.minimum_email_score ||= 85
        self.contactLimit ||= 100
    end

    def self.defaultCampaignChoice
        return "-- Default --"
    end
end
