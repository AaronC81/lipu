require 'tk'
require_relative 'everything'

window = TkRoot.new do
    overrideredirect true
    raise
    wm_attributes "topmost", true
    wm_attributes "alpha", 0.8
    geometry "400x400+0+0"

    grid_columnconfigure 0, weight: 1, uniform: "col"
    grid_columnconfigure 1, weight: 1, uniform: "col"
    grid_columnconfigure 2, weight: 1, uniform: "col"
    grid_columnconfigure 3, weight: 1, uniform: "col"
end

TkLabel.new(window) do
    text "lipu"
    grid row: 0, column: 0, columnspan: 3, sticky: "nsew"
end

TkButton.new(window) do
    text "Settings"
    grid row: 0, column: 3, sticky: "nsew"
end

search_term = TkVariable.new
TkEntry.new(window) do
    textvariable search_term
    grid row: 1, column: 0, columnspan: 4, sticky: "nsew"
end.focus

search_result_widgets = []

search_term.trace("w") do 
    search_result_widgets.map do |w|
        w.grid_forget
        w.destroy
    end
    search_result_widgets.clear

    query = Everything::Query.new
    query.search = search_term.value
    query.execute
    Everything.results.take(5).each.with_index do |result, i|
        search_result_widgets << TkLabel.new(window) do
            text result.file_name
            anchor "w"
            grid row: 2 + i, column: 0, columnspan: 4, sticky: "nsew"
        end
    end
end



Tk.mainloop
