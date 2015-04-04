require 'rubygems'
require 'gosu'

class TextField < Gosu::TextInput
  # Some constants that define our appearance.
  INACTIVE_COLOR  = 0xcc666666
  ACTIVE_COLOR    = 0xccff6666
  SELECTION_COLOR = 0xcc0000ff
  CARET_COLOR     = 0xffffffff
  PADDING = 5

  attr_reader :x, :y

  def initialize(window, font, x, y)
    super()
    @window, @font, @x, @y = window, font, x, y
    self.text = "Click to change text"
  end

  def filter text
    text.upcase
  end

  def draw
    if @window.text_input == self then
      background_color = ACTIVE_COLOR
    else
      background_color = INACTIVE_COLOR
    end
    @window.draw_quad(x - PADDING,         y - PADDING,          background_color,
                      x + width + PADDING, y - PADDING,          background_color,
                      x - PADDING,         y + height + PADDING, background_color,
                      x + width + PADDING, y + height + PADDING, background_color, 0)

    # Calculate the position of the caret and the selection start.
    pos_x = x + @font.text_width(self.text[0...self.caret_pos])
    sel_x = x + @font.text_width(self.text[0...self.selection_start])

    @window.draw_quad(sel_x, y,          SELECTION_COLOR,
                      pos_x, y,          SELECTION_COLOR,
                      sel_x, y + height, SELECTION_COLOR,
                      pos_x, y + height, SELECTION_COLOR, 0)

    if @window.text_input == self then
      @window.draw_line(pos_x, y,          CARET_COLOR,
                        pos_x, y + height, CARET_COLOR, 0)
    end

    @font.draw(self.text, x, y, 0)
  end

  def width
    @font.text_width(self.text)
  end

  def height
    @font.height
  end

  def under_point?(mouse_x, mouse_y)
    mouse_x > x - PADDING and mouse_x < x + width + PADDING and
      mouse_y > y - PADDING and mouse_y < y + height + PADDING
  end

  def move_caret(mouse_x)
    1.upto(self.text.length) do |i|
      if mouse_x < x + @font.text_width(text[0...i]) then
        self.caret_pos = self.selection_start = i - 1;
        return
      end
    end
    self.caret_pos = self.selection_start = self.text.length
  end
end

class TextInputWindow < Gosu::Window
  def initialize
    super(300, 200, false)
    self.caption = "Text Input Example"
    font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @text_fields = Array.new(3) { |index| TextField.new(self, font, 50, 30 + index * 50) }
    @cursor = Gosu::Image.new(self, "models/images/test2.png", false)
  end

  def draw
    @text_fields.each { |tf| tf.draw }
    @cursor.draw(mouse_x, mouse_y, 0)
  end

  def button_down(id)
    if id == Gosu::KbTab then
      # Tab key will not be 'eaten' by text fields; use for switching through
      # text fields.
      index = @text_fields.index(self.text_input) || -1
      self.text_input = @text_fields[(index + 1) % @text_fields.size]
    elsif id == Gosu::KbEscape then
      if self.text_input then
        self.text_input = nil
      else
        close
      end
    elsif id == Gosu::MsLeft then
      self.text_input = @text_fields.find { |tf| tf.under_point?(mouse_x, mouse_y) }
      self.text_input.move_caret(mouse_x) unless self.text_input.nil?
    end
  end
end

TextInputWindow.new.show
