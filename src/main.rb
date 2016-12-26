require 'gosu'

if $DEBUG
  require 'pry'
end

class GameWindow < Gosu::Window
  def initialize
    super 1600, 900
    self.caption = "PF"

    @kp_sprite = generate_kp_sprite
    @background = Background.new("background_01.png")
  end

  def update
    if Gosu::button_down? Gosu::KbLeft or Gosu::button_down? Gosu::GpLeft then
      @background.left
      @kp_sprite.left
    end
    if Gosu::button_down? Gosu::KbRight or Gosu::button_down? Gosu::GpRight then
      @background.right
    end
    if Gosu::button_down? Gosu::KbDown or Gosu::button_down? Gosu::GpDown then
      @background.down
    end
    if Gosu::button_down? Gosu::KbUp or Gosu::button_down? Gosu::GpUp then
      @background.up
    end
  end

  def draw
    @kp_sprite.draw
    @background.draw
  end

  private
  def generate_kp_sprite
    left = Animation.new("kp_left_walk", 397, 568, 3)
    right = Animation.new("kp_right_walk", )
    up = Animation.new("kp_walk_up")
    down = Animation.new("kp_walk_down")

    return Sprite.new(up, down, left, right)
  end
end

class ResourceManager
  RESOURCES_PATH="../resources"

  def self.load_animation(filename, width, height)
    frames = Gosu::Image::load_tiles("#{RESOURCES_PATH}/images/#{filename}", width, height)
    if(!frames.empty?)
      return frames
    else
      raise IOError, "File not Found: #{filename} (#{RESOURCES_PATH}/images/#{filename})"
    end
  end

  def self.load_image(filename, options={})
    image = Gosu::Image.new("#{RESOURCES_PATH}/images/#{filename}", options)
    if (!image.nil?)
      return image
    else
      raise IOError, "File Not Found #{filename}"
    end
  end
end

module ZOrder
  BG, Sprites = *0..1
end

ANIMATION_FRAME_RATE = 30
FRAME_WIDTH = 397
FRAME_HEIGHT = 568

class Animation
  def initialize(filename, width, height, framerate)
    @frames = ResourceManager.load_animation(filename, width, height)
    @current_frame = 0
    @previous_time = Time.new
    @framerate = framerate
  end

  def setFrame (frame)
    @current_frame = frame
  end

  def draw(x, y, z)
    current_time = Time.new
    if(current_time.to_f - @previous_time.to_f  >= 1.to_f/@framerate)
      @previous_time = current_time
      if(@current_frame >= @frames.length-1)
        @current_frame = 0
      else
        @current_frame += 1
      end
    end
    @frames[@current_frame].draw(x, y, z)

  end
end

class Sprite
  def initialize(walk_up, walk_down, walk_left, walk_right)
    @pos_x = @pos_y = 0
    @step_size = 10

    @up_walk = walk_up
    @down_walk = walk_down
    @right_walk = walk_right
    @left_walk = walk_left
    @current_animation = @left_walk
  end

  def warp(x, y)
    @pos_x = x;
    @pos_y = y;
  end

  def down
    @pos_y += @step_size
    @current_animation = @down_walk
  end

  def up
    @pos_y -= @step_size
    @current_animation = @up
  end

  def left
    @pos_x -= @step_size
    @current_animation = @left_walk
  end

  def right
    @pos_x += @step_size
    @current_animation = right_walk
  end

  def draw
    @current_animation.draw(@pos_x, @pos_y, ZOrder::Sprites)
  end
end

class Background
  def initialize(filename)
    @pos_x = @pos_y = 0;
    @image = ResourceManager.load_image(filename, :tileable=>true)
  end

  def warp(x, y)
    @pos_x = x;
    @pos_y = y;
  end

  def down
    @pos_y += 10
  end

  def up
    @pos_y -= 10
  end

  def left
    @pos_x -= 10
  end

  def right
    @pos_x += 10
  end

  def draw
    @image.draw(@pos_x, @pos_y, ZOrder::BG)
  end
end

if __FILE__ == $0
  window = GameWindow.new
  window.show
end
