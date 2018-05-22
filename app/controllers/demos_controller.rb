class DemosController < ApplicationController


	def create
 
		if  Demo.create(demo_params)
			redirect_to root_path, :notice => "Your demo request has been sent. A team member will be in contact with you shortly!"
		else
			redirect_to root_path, :notice => "Could not send demo request!"
		end

	end


	private


	def demo_params
      params.require(:demo).permit(:name, :email, :phone_number, :comments)
	end


end
