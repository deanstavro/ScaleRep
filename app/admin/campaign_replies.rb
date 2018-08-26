ActiveAdmin.register CampaignReply do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :lead, :lead_id, :client_company_id, :first_name, :last_name, :full_name, :email, :status, :last_conversation_summary, :last_conversation_subject, :follow_up_date, :company, :notes, :reply_io_key, :referral_email, :referral_name, :pushed_to_reply_campaign

# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

remove_filter :lead

index do
    selectable_column
    id_column

    column :lead_id
  	column :client_company_id
  	column :first_name
  	column :last_name
  	column :full_name
  	column :email
  	column :status
  	column :last_conversation_summary
  	column :last_conversation_subject
  	column :follow_up_date
  	column :company
  	column :notes
  	column :reply_io_key
    column :referral_name
    column :referral_email
    column :pushed_to_reply_campaign

  	 actions
end



form do |f|
  f.inputs "Admin Details" do
  	f.input :lead_id
  	f.input :client_company_id
  	f.input :first_name
  	f.input :last_name
  	f.input :full_name
  	f.input :email
  	f.input :status
  	f.input :last_conversation_summary
  	f.input :last_conversation_subject
  	f.input :follow_up_date
  	f.input :company
  	f.input :notes
  	f.input :reply_io_key
    f.input :referral_name
    f.input :referral_email
    f.input :pushed_to_reply_campaign

end
  f.actions
end

end
