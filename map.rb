class Map
  attr_reader :rows, :columns, :block_size, :file
  attr_accessor :grid

  def initialize(rows, columns, filepath)
    @rows = rows
    @columns = columns
    @grid = Array.new(rows) { |i| Array.new(columns) { |j| 255 } }
    @file = filepath
  end

  def save

  end
end
