module DataUploadsHelper

	def clean_import_data(data_upload, page, per_page)
        # page is the page edited
        cleaned_data_copy = data_upload.cleaned_data
        headers = data_upload.data[0].keys 
        client_company = data_upload.campaign.client_company
        new_cleaned_hash = []
        row_array = []
        
        # set the lead count of the page, and end count of the page (ex 1201 - 1350)
        lead_start = ((page.to_i - 1)*per_page.to_i) + 1
        lead_end = ((page.to_i)*per_page.to_i)

        # If editing page > 1, copy the contents before
        if page > 1
          #copy cleaned_data into new array up until page
          cleaned_data_copy[0...lead_start-1].each do |clean_data|
              new_cleaned_hash << clean_data
          end
        end

        # Loop through the rows (params) of the page edited, to add in the page values
        previous_row = "0"
        params_copy = params.dup.except(:controller,:action, :commit, :authenticity_token, :data_upload, :utf8, :page, :per_page)
        params_copy.each do |key, value|
            row_index_string = key.split("_")[0].to_s
            column_index_string = key.split("_")[1].to_s
            if row_index_string == previous_row
              #put values of edited columns for the row in the row_array
              row_array << value
            else
              # new row
              previous_row = row_index_string
              new_cleaned_hash << Hash[headers.zip(row_array)]
              row_array = []
              row_array << value
            end
        end

        # Add page with edits
        new_cleaned_hash << Hash[headers.zip(row_array)]
        
        # Copy remaining pages
        begin
          cleaned_data_copy[lead_end..-1].each do |clean_data|
              new_cleaned_hash << clean_data
          end
        rescue
            puts "out of range"
        end
        data_upload.update_attribute(:cleaned_data, new_cleaned_hash)
    end
end
