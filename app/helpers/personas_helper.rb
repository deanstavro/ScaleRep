module PersonasHelper

	def sortable(column, title = nil)
        title ||= column.titleize
        direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
        link_to title, {:sort => column, :direction => direction}
    end

    private

    def sort_column
        Lead.column_names.include?(params[:sort]) ? params[:sort] : "full_name"
    end
  
    def sort_direction
        %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

end
