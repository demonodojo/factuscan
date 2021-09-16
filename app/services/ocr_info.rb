class OcrInfo < Object
  attr_accessor :definition, :match_included, :ends_with

  def initialize(definition)
    @definition = definition.with_indifferent_access
    @match_included = false
    @ends_with = false
  end

  def search_line(text)
    lines.select { |line| compare_line_text(line, text) }.first
  end
  def search_line_index(text)
    lines.each_with_index do |line, index|
      return index if compare_line_text(line, text)
    end
    -1
  end

  def search_prev_line(text)
    index = search_line_index(text)
    return {} unless index > 0
    lines[index - 1]
  end

  def search_next_line(text)
    index = search_line_index(text)
    return {} unless index >= 0
    lines[index + 1]
  end


  def search_below_line(text)
    index = search_line_index(text)
    rest_lines = lines[index + 1..-1]
    current_line = lines[index]
    min_top = current_line[:top].to_f + current_line[:height].to_f
    min_left = current_line[:left].to_f
    rest_lines.each do |line|
      return line if line[:top].to_f > min_top && line[:left] > min_left
    end
    {}
  end

  def line_above(current_line)
    min_bottom = current_line[:top].to_f
    min_left = current_line[:left].to_f
    selected_line = lines[0]
    lines.each do |line|
      return selected_line if line == current_line

      if line[:top] + line[:height] < min_bottom && line[:left] > min_left
        selected_line = line
      end
    end
    selected_line
  end

  def search_nearest_line(top, left)
    found = lines[0]
    best_distance = 10000000000
    lines.each do |line|
      distance = euclidean_distance([top, left], [line[:top], line[:left]])
      if distance < best_distance
        found = line
        best_distance = distance
      end
    end
    found
  end

  def search_line_text(text)
    search_line(text)[:text]
  end

  def search_prev_line_text(text)
    search_prev_line(text)[:text]
  end

  def search_next_line_text(text)
    search_next_line(text)[:text]
  end

  def search_below_line_text(text)
    search_below_line(text)[:text]
  end

  def search_nearest_line_text(top, left)
    search_nearest_line(top, left)[:text]
  end

  def lines
    @definition[:lines]
  end

  def detect_type
    Invoice.subclasses.each do |subclass|
      return subclass.name if subclass.is_mine?(self)
    end
    nil
  end

  def compare_line_text(line, text)
    compare_strings(line[:text], text)
  end

  def compare_strings(line_text, text)
    return line_text.parameterize.end_with? text.parameterize if ends_with
    return line_text.parameterize.include? text.parameterize if match_included

    line_text.parameterize == text.parameterize
  end

  def using_included
    self.match_included = true
    begin
      yield
    ensure
      self.match_included = false
    end
  end

  def using_ends_with
    self.ends_with = true
    begin
      yield
    ensure
      self.ends_with = false
    end
  end

  def euclidean_distance(point1, point2)
    # First; group the x's and y's, then sum the squared difference in x's and y's
    Math.sqrt(point1.zip(point2).reduce(0) { |sum, p| sum + (p[0] - p[1]) ** 2 })
  end

  def page
    definition[:page]
  end
  def coords(width, line)
    real_width = width * page[:width]
    real_height = width / page[:height]

    [ line[:left] * real_width, (line[:top] + line[:height]) * real_height, (line[:left] + line[:width]) * real_width, line[:top] * real_height ]
  end
end
