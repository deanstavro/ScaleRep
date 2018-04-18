ActiveAdmin.register User do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :client_company_id, :email, :encrypted_password, :name, :role, :password, :password_confirmation

form do |f|                         
  f.inputs "User Details" do       
    f.input :name
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
#
# or
#
#permit_params do
#   permitted = [:client_company, :email, :encrypted_password, :name, :role]
#   permitted << :other if params[:action] == 'create' #&& current_user.admin?
#   permitted
#end

end
