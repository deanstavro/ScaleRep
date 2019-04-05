class Campaign < ApplicationRecord
	has_many :leads
	has_many :data_uploads
	has_many :touchpoints
	
	belongs_to :client_company
    belongs_to :persona

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
        self.campaign_start ||= Date.today
        self.campaign_end ||= Date.today + 30.days
        self.contactLimit ||= 100
    end

    # Default Accounts to use for campaign
    def self.defaultCampaignChoice
        return "-- Default --"
    end
end
