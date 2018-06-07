class AccountsController < InheritedResources::Base
	before_action :authenticate_user!



  private

    def account_params
      params.require(:account).permit()
    end
    
end

