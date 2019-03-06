ActiveAdmin.register ClientCompany do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :name, :company_domain, :replyio_keys, :api_key, :account_live, :account_manager, :auto_reply_campaign_key, :auto_reply_campaign_id, :referral_campaign_key, :referral_campaign_id, :monthlyContactEngagementCount, :clientDirectorNotes

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
    column :monthlyContactEngagementCount

    column :replyio_keys
    column :auto_reply_campaign_key
    column :auto_reply_campaign_id
    column :referral_campaign_key
    column :referral_campaign_id

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

    f.input :monthlyContactEngagementCount

    f.input :replyio_keys
    f.input :auto_reply_campaign_key
    f.input :auto_reply_campaign_id
    f.input :referral_campaign_key
    f.input :referral_campaign_id


    f.input :clientDirectorNotes
    
    f.input :api_key, label: "api_key - overriden on creation, can edit after"

  end
  f.actions
end

end
