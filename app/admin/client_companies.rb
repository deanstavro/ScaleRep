ActiveAdmin.register ClientCompany do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :name, :description, :company_domain, :company_notes, :replyio_keys, :api_key, :number_of_seats, :emails_to_use, :products, :notable_clients, :profile_setup, :account_live, :account_manager, :auto_reply_campaign_key, :auto_reply_campaign_id, :referral_campaign_key, :referral_campaign_id
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

form do |f|
  f.inputs "Client Company Details" do

    f.input :name
    f.input :company_domain
    f.input :account_manager
    f.input :description
    f.input :company_notes
    f.input :replyio_keys
    f.input :number_of_seats
    f.input :emails_to_use
    f.input :products
    f.input :notable_clients
    f.input :profile_setup
    f.input :account_live
    f.input :api_key
    f.input :auto_reply_campaign_key
    f.input :auto_reply_campaign_id
    f.input :referral_campaign_key
    f.input :referral_campaign_id


  end
  f.actions
end

end
