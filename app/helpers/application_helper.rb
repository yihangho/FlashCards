module ApplicationHelper
  def select_options_arr(arr, selected_val, value_sym, label_sym)
    output = arr.map do |item|
      selected = selected_val.include?(item.send(value_sym))
      [item.send(label_sym), item.send(value_sym), {"selected" => selected}]
    end
    options_for_select output
  end
end
