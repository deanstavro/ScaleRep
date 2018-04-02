class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_only, :except => :show

  def index
    @users = User.all
  end

  def show

    @user = User.find(params[:id])
    @company = @user.client_company_id
    
    @leads = Lead.where("client_company_id =? " , @company)
    @ordered_leads = @leads.sort_by &:date_sourced
    

    #@leads_count = @leads.count
    #@contracts = @leads.where(contract_amount: 1..Float::INFINITY).sort_by &:date_sourced
    #@contracts_given = @contracts.sort_by &:date_sourced
    #@contracts_count = @contracts_given.count
    #@unconverted = @leads.count - @contracts_given.count


    
    #Create line chart value for aggregated proposed deal sizes
    lead_proposed_dictionary = {}
    @ordered_leads.each do |lead|

      #key, value of all leads and deals

      if lead_proposed_dictionary.has_key?(lead[:date_sourced])
        lead_proposed_dictionary[lead[:date_sourced]] += lead[:potential_deal_size]        

      else
        lead_proposed_dictionary[lead[:date_sourced]] = lead[:potential_deal_size]

      end

    end

    


    if lead_proposed_dictionary.count > 1
      total_qua_rev = 0
    

      lead_proposed_dictionary.each { |key, value|

        total_qua_rev += value
        puts "#{key} #{value}"
        lead_proposed_dictionary[key] = total_qua_rev
        }
    end

    @lead_proposed_dictionary = lead_proposed_dictionary


    #Create line chart value for aggregated contract deal sizes
    lead_contract_dictionary = {}
    @ordered_leads.each do |lead|


      #key, value of all leads and deals

      if lead_contract_dictionary.has_key?(lead[:date_sourced])
        lead_contract_dictionary[lead[:date_sourced]] += lead[:contract_amount]        


      else
      lead_contract_dictionary[lead[:date_sourced]] = lead[:contract_amount]

      end

    end


    if lead_contract_dictionary.count > 1
      total_qua_rev = 0
      lead_contract_dictionary.each { |key, value|

        total_qua_rev += value
        puts "#{key} #{value}"
        lead_contract_dictionary[key] = total_qua_rev
        }
    end

    @lead_contract_dictionary = lead_contract_dictionary



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
