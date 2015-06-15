# need chunky_png gem - prerequisite to using oily_png
# oily_png allows for faster image manipulation
require 'oily_png'
require 'pry'
require 'gosu'
require_relative 'map'

  SIZE = ARGV[1]
  NAME = ARGV[0]
  GRID_SIZE = ARGV[2].to_i
  SIZES = SIZE.split("x").map { |block| block.to_i * GRID_SIZE }
  size = "#{SIZES[0]}x#{SIZES[1]}"

  system "convert -size #{SIZE} xc:white #{NAME}.png"

  puts e.backtrace




class Game < Gosu::Window

  SCREEN_WIDTH = SIZES[0]
  SCREEN_HEIGHT = SIZES[1]

  def initialize()


    super(SCREEN_WIDTH, SCREEN_HEIGHT, false)
    # map will in turn be used as a key (vals = color/can be r,g,b 256 or hex) to tell gosu what 'tiles'
    # and 'objects|enemies' are rendered where.  for this case we will use only the red value.
    # the g/b values are different but only serve to help distinguish different
    # ground - 0     ChunkyPNG::Color.r(coordinates of pixel) => red 0-255 scale.
    # mario - 1
    # goomba - 2
    @mx = 0
    @my = 0
    @state = nil
    @block_size = GRID_SIZE
    @row = SIZES[1] / @block_size
    @col = SIZES[0] / @block_size
    @map = Map.new(@row, @col, NAME)
    @active_image = nil
    @png = ChunkyPNG::Image.from_file("#{NAME}.png")
    @images = Array.new
    (0..@png.dimension.height-1).each do |y|
      (0..@png.dimension.width-1).each do |x|
        key = ChunkyPNG::Color.r(@png[x, y])
        @map.grid[y][x] = key
      end
    end

    #assign images to corresponding mapped values.
    @images[0] = Gosu::Image.new(self, './models/images/ground.png')
    @images[1] = Gosu::Image.new(self, './models/images/mario.png')
    @images[2] = Gosu::Image.new(self, './models/images/goomba.png')
    @background = Gosu::Image.new(self, './models/images/testmap.png')
  end

  def draw_tile(col, row, val)
    px = to_px(col, row)
    @images[val].draw(px[1], px[0], 1, @block_size.to_f / @images[@active_image].width, @block_size.to_f / @images[@active_image].height)
  end

  def get_coords
    x, y = ((@mx.to_f / self.width) * @col).to_i, ((@my.to_f / self.height) * @row).to_i
  end

  def to_px(col, row)
    x = col * @block_size
    y = row * @block_size
    [x, y]
  end

  def draw_mouse
    if !@active_image.nil?
      @images[@active_image].draw(@mx, @my, 2, @block_size.to_f / @images[@active_image].width, @block_size.to_f / @images[@active_image].height )
    end
  end
  def draw
    draw_mouse
    @background.draw(0, 0, 0, SCREEN_WIDTH/@background.width, SCREEN_HEIGHT/@background.height)
    @map.grid.each_with_index do |_, i|
      _.each_with_index do |val, j|
        draw_tile(i, j, val) unless val == 255
      end
    end
  end

  def add_tile
    coords = get_coords
    x, y = coords[0], coords[1]
    @map.grid[y][x] = @active_image
  end

  def update
    @mx = mouse_x
    @my = mouse_y
    if @state == "painting"
      add_tile
    end
  end

  def flash_message(text)


  end

  def save_map
    @map.grid.each_with_index do |col, i|
      col.each_with_index do |value, j|
        @png[i,j] = ChunkyPNG::Color.rgb(value, 0, 0)
      end
    end
    @png.save("#{NAME}.png")
  end

  def button_down(key)

    case key

    when 20
      @active_image = 0
    when 26
      @active_image = 1
    when 8
      @active_image = 2
    when Gosu::KbS
      save_map
    when 256
      @state = "painting"
    when Gosu::KbEscape
      close
    end
  end

  def button_up(key)
    @state = nil if key == 256
  end
end

game = Game.new
game.show
end
