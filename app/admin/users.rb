ActiveAdmin.register User do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#

permit_params :client_company_id, :email, :encrypted_password, :first_name, :last_name, :role, :password, :password_confirmation, :api_key

remove_filter :data_uploads


index do
    selectable_column
    id_column

    column :first_name
    column :last_name
    column :email
    column :client_company
    column :role
    column :last_sign_in_at
    column :last_sign_in_ip
    column :current_sign_in_at
    column :current_sign_in_ip
    column :api_key
    column :created_at
    column :updated_at


    actions

end



form do |f|                         
    f.inputs "User Details" do       
    f.input :first_name
    f.input :last_name
    f.input :email
    f.input :role
    f.input :client_company
    f.input :password
    f.input :password_confirmation
    
  end                               
  f.actions                         
end

def update
   @user = User.find(params[:id])
   if params[:user][:encrypted_password].blank?
     @user.update_without_password(params[:user])
   else
     @user.update_attributes(params[:user])
   end
   if @user.errors.blank?
     redirect_to admin_users_path, :notice => "User updated successfully."
   else
     render :edit
   end
 end
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

end
