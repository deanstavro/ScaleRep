ActiveAdmin.register Campaign do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#

permit_params :reply_id, :reply_key, :persona, :user_notes, :industry, :campaign_start, :campaign_end, :client_company_id, :name, :personalized, :persona_id, :last_poll_from_reply, :deliveriesCount, :opensCount, :repliesCount, :bouncesCount, :optOutsCount, :outOfOfficeCount, :peopleCount, :peopleFinished, :peopleActive, :peoplePaused



# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end
form do |f|                         
  f.inputs "Admin Details" do
  	f.input :client_company  
    f.input :name
    f.input :persona
    f.input :personalized
       
    
    f.input :reply_id
    f.input :reply_key
    
    f.input :user_notes
    f.input :industry
    f.input :campaign_start
    f.input :campaign_end

    f.input :last_poll_from_reply
    f.input :deliveriesCount
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
