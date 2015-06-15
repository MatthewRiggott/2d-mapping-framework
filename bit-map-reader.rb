# need chunky_png gem - prerequisite to using oily_png
# oily_png allows for faster image manipulation
require 'oily_png'
require 'pry'
require 'gosu'

class Game < Gosu::Window


  SCREEN_WIDTH = 20 * 64
  SCREEN_HEIGHT = 10 * 64

  def initialize()


    super(SCREEN_WIDTH, SCREEN_HEIGHT, false)
    # map will in turn be used as a key (vals = color/can be r,g,b 256 or hex) to tell gosu what 'tiles'
    # and 'objects|enemies' are rendered where.  for this case we will use only the red value.
    # the g/b values are different but only serve to help distinguish different
    # ground - 0     ChunkyPNG::Color.r(coordinates of pixel) => red 0-255 scale.
    # mario - 1
    # goomba - 2
    @row = 10
    @col = 20
    @map = Array.new(@row) { |i| Array.new(@col) { |j| 255 } }
    image = ChunkyPNG::Image.from_file('map2.png')

    @images = Array.new
    (0..image.dimension.height-1).each do |y|
      (0..image.dimension.width-1).each do |x|
        key = ChunkyPNG::Color.r(image[x, y])
        @map[y][x] = key
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
    @images[val].draw(px[1], px[0], 1)
  end

  def to_px(col, row)
    x = col * 64
    y = row * 64
    [x, y]
  end

  def button_down(key)
    if key == Gosu::KbEscape
      close
    end
  end

  def draw
    @background.draw(0, 0, 0, SCREEN_WIDTH/@background.width, SCREEN_HEIGHT/@background.height)
    (0..@row-1).each do |i|
      (0..@col-1).each do |j|
        draw_tile(i, j, @map[i][j]) unless @map[i][j] == 255
      end
    end
  end
end

game = Game.new
game.show
