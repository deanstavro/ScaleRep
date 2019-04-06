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


  # Takes keys of csv, and checks if csv is processable
  # Returns keys, unused keys, data, and coutn
  # Returns nil if first_name and email are not present
  # Returns nil if duplicate column that will be uploaded
  # Ignores columns that will not be used
  def self.check_default_rules_of_uploaded_csv(file)
  	lines = CSV.open(file.path).readlines
    keys = lines.delete lines.first
  	# Record keys used and unused
  	new_keys = Hash.new
    keys_unused = []
  	#Checks for email and first_name
    email_exists = false
    first_name_exists = false
    # Loop through Keys
    keys.each_with_index do |key, index|
      begin
        key_to_insert = key.downcase
        
        if Lead.lead_import_columns.include? key_to_insert
          if new_keys[key_to_insert].nil?
            new_keys[key_to_insert] = index
            email_exists = true if key_to_insert == "email"
            first_name_exists = true if key_to_insert == "first_name"
          else
            # Duplicate columns
            return "error. Two columns named " + key_to_insert, nil
          end
        else
          # unused header
          keys_unused << index
        end
      rescue
        # could not read
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
            Hash[keys_array.zip(new_value)]
        end
        data = data_ob
    end

    return keys_array, keys_unused, data, count
  end

end