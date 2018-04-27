module Reply
  class NewContacts

    attr_reader :key

    def initialize(company,lead)
      puts "HEYYYYY"
      @key = company.replyio_keys
      @base = "https://api.reply.io/v2/"
      @lead = lead


    end

    def fetch()
      payload = { "campaignId": one_hash["campaign_name"], "email": one_hash["email"], "firstName": one_hash["first_name"], "lastName": one_hash["last_name"] }
	  puts payload
	  puts company.replyio_keys
	
	  response = RestClient::Request.execute(
							:method => :post,
							:url => 'https://api.reply.io/v1/actions/addandpushtocampaign?apiKey='+company.replyio_keys,
							:payload => payload

	  puts response

    
  end
end