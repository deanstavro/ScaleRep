class AccountsController < InheritedResources::Base

  private

    def account_params
      params.require(:account).permit()
    end
end

