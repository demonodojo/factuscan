module InvoicesHelper

  def calculate_map(name, ocr_info, width)
    return "" unless ocr_info

    content_tag :map, name: name do
      ocr_info.lines.each do |line|
        concat(
          tag.area(shape: 'rect',
                   coords: ocr_info.coords(width, line).join(","),
                   "data-maphilight": '{"strokeColor":"666600","strokeWidth":2,"fillColor":"ffffcc","fillOpacity":0.2,"alwaysOn":false}',
                   title: line[:text]
        ))
      end
    end
  end
end
