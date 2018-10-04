ActiveAdmin.register Touchpoint do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :campaign, :lead_id, :email_subject, :email_body, :sender_email, :channel

remove_filter :lead
remove_filter :campaign

index do
    selectable_column
    id_column

    column :campaign
    column :lead_id
    column :email_subject
    column :sender_email
    column :channel

    actions
  end



end
