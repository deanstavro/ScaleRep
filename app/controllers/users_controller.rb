class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_only, :except => :show

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])

    @company = ClientCompany.find_by(id: @user.client_company_id)
    @leads = Lead.where("client_company_id =? " , @company)
    
    @contracts_given = @leads.where("contract_sent =?", 'yes')
    @contracts_count = @contracts_given.count
    @leads_count = @leads.count
    @unconverted = @leads.count - @contracts_given.count


    @weekly_amount_cont_array = @leads.group_by_week(:date_sourced).sum(:contract_amount)
    @weekly_amount_qual_rev_array = @leads.group_by_week(:date_sourced).sum(:potential_deal_size)
    @weekly_amount_won_array = @leads.group_by_week(:date_sourced).sum(:deal_size)

    
    total_qua_rev = 0
    @weekly_amount_cont_array.each { |key, value|

      total_qua_rev += value
      puts "#{key} #{value}"
      @weekly_amount_cont_array[key] = total_qua_rev
       }




    total_qua_rev = 0
    @weekly_amount_qual_rev_array.each { |key, value|

      total_qua_rev += value
      puts "#{key} #{value}"
      @weekly_amount_qual_rev_array[key] = total_qua_rev
       }

    total_qua_rev = 0
    @weekly_amount_won_array.each { |key, value|

      total_qua_rev += value
      puts "#{key} #{value}"
      @weekly_amount_won_array[key] = total_qua_rev
       }





    unless current_user.admin?
      unless @user == current_user
        redirect_to root_path, :alert => "Access denied."
      end
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(secure_params)
      redirect_to users_path, :notice => "User updated."
    else
      redirect_to users_path, :alert => "Unable to update user."
    end
  end

  def destroy
    user = User.find(params[:id])
    user.destroy
    redirect_to users_path, :notice => "User deleted."
  end

  private

  def admin_only
    unless current_user.admin?
      redirect_to root_path, :alert => "Access denied."
    end
  end

  def secure_params
    params.require(:user).permit(:role)
  end

end
