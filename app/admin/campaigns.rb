ActiveAdmin.register Campaign do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#

permit_params :reply_id, :reply_key, :contactLimit, :persona, :campaign_start, :campaign_end, :client_company_id, :persona_id, :last_poll_from_reply, :deliveriesCount, :uniquePeopleContacted, :opensCount, :uniqueOpens, :repliesCount, :bouncesCount, :optOutsCount, :outOfOfficeCount, :peopleCount, :peopleFinished, :peopleActive, :peoplePaused, :campaign_name, :archive, :email_pool, :emailAccount



# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end
remove_filter :leads
remove_filter :persona
remove_filter :touchpoints
remove_filter :data_uploads

form do |f|
  f.inputs "Admin Details" do
    f.input :archive
  	f.input :client_company
    f.input :campaign_name
    f.input :persona
    f.input :contactLimit
    f.input :emailAccount
    f.input :email_pool, as: :json

    f.input :reply_id
    f.input :reply_key

    f.input :campaign_start
    f.input :campaign_end

    f.input :last_poll_from_reply
    f.input :deliveriesCount
    f.input :uniqueOpens
    f.input :uniquePeopleContacted
    f.input :opensCount
    f.input :repliesCount
    f.input :bouncesCount
    f.input :optOutsCount
    f.input :outOfOfficeCount
    f.input :peopleCount
    f.input :peopleFinished
    f.input :peopleActive
    f.input :peoplePaused

end
  f.actions
end

end
