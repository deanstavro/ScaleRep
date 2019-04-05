class DataUpload < ApplicationRecord
  belongs_to :client_company
  belongs_to :campaign
  belongs_to :user
  serialize :rules, Array

  def self.pass_upload_requirements(file)
  	# Defined Rules for File Upload
  	if file.nil?
  		return false, "CSV file not included - please include CSV"
  	elsif file.content_type.to_s != 'text/csv'
  		return false, "The file is not a CSV"
  	elsif file.size.to_i > 1000000
  		return false, "CSV file is too large. Please upload a shorter CSV"
  	else
  		return true, "Success"
  	end
  end

  # Loops through a file. Checks if first_name and email are present
  # Save Data_Upload object with data as a hash
  def self.upload_data(file, company, campaign, column_names, user)
		puts "Starting lead import to campaign"
		
		lines = CSV.open(file.path).readlines
		keys = lines.delete lines.first
		new_keys = Hash.new
		keys_unused = []
	
		email_exists = false
		first_name_exists = false

		# Check for required keys
		keys.each_with_index do |key, index|
			begin
				key_to_insert = key.downcase
				if column_names.include? key_to_insert
					if new_keys[key_to_insert].nil?
						new_keys[key_to_insert] = index
						email_exists = true if key_to_insert == "email"
						first_name_exists = true if key_to_insert == "first_name"
					else
						# Duplicate columns
						return "error. Two columns named " + key_to_insert, nil
					end
				else
					puts "empty header"
					keys_unused << index
				end
			rescue
				puts "could not read column name"
				keys_unused << index
			end
		end
		keys_array = new_keys.keys

		# check for required fields in the header
		if first_name_exists == false
			return "first_name header not included. List not uploaded", nil
		elsif email_exists == false
			return "email header not included. List not uploaded", nil
		end

		count = 0
		data = nil
		# Open file and create json from it
		File.open(file.path, "w") do |f|
  			data_ob = lines.map do |values|
  				count = count + 1
  				!!(values =~ /^[-+]?[1-9]([0-9]*)?$/) ? values.to_i : values.to_s
  				
  				new_value = values.reject.with_index {|e, x| keys_unused.include? x}
  				puts new_value.to_s
    			Hash[keys_array.zip(new_value)]
  			end
  			puts JSON.pretty_generate(data_ob)
  			data = data_ob
		end
		new_data_upload = DataUpload.create(client_company: company, campaign: campaign, user: user, data: data, count: count, headers: keys_array.to_s)
		return count.to_s + " records uploaded. Columns " + keys_array.to_s + " included.", new_data_upload
	end
end