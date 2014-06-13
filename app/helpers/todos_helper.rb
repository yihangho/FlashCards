module TodosHelper
  def select_options_arr(arr, selected_id)
    output = arr.map do |item|
      selected = selected_id.include?(item.id)
      [item.word, item.id, {"selected" => selected}]
    end
    options_for_select output
  end
end
