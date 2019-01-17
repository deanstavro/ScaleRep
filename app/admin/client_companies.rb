ActiveAdmin.register ClientCompany do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :name, :description, :company_domain, :company_notes, :replyio_keys, :api_key, :number_of_seats, :emails_to_use, :products, :notable_clients, :account_live, :account_manager, :auto_reply_campaign_key, :auto_reply_campaign_id, :referral_campaign_key, :referral_campaign_id, :monthlyContactProspectingCount, :monthlyContactEngagementCount, :clientDirectorNotes

remove_filter :leads
remove_filter :campaign_replies
remove_filter :users
remove_filter :personas
remove_filter :accounts
remove_filter :campaigns
remove_filter :data_uploads
remove_filter :touchpoints
remove_filter :lead_actions

index do
    selectable_column
    id_column

    column :name
    column :company_domain
    column :account_manager
    column :account_live
    column :monthlyContactProspectingCount
    column :monthlyContactEngagementCount

    column :replyio_keys
    column :auto_reply_campaign_key
    column :auto_reply_campaign_id
    column :referral_campaign_key
    column :referral_campaign_id

    column :description
    column :company_notes
    column :number_of_seats
    column :emails_to_use
    column :products
    column :notable_clients
    column :clientDirectorNotes

    column :api_key
    column :created_at
    column :updated_at

    actions

end

form do |f|
  f.inputs "Client Company Details" do

    f.input :name
    f.input :company_domain
    f.input :account_manager
    f.input :account_live, label: "account live - check if client is currently using platform"
    f.input :monthlyContactProspectingCount
    f.input :monthlyContactEngagementCount

    f.input :replyio_keys
    f.input :auto_reply_campaign_key
    f.input :auto_reply_campaign_id
    f.input :referral_campaign_key
    f.input :referral_campaign_id


    f.input :description
    f.input :company_notes
    
    f.input :number_of_seats
    f.input :emails_to_use
    f.input :products
    f.input :notable_clients
    f.input :clientDirectorNotes
    
    f.input :api_key, label: "api_key - overriden on creation, can edit after"

  end
  f.actions
end

end
