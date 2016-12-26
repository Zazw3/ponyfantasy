require 'gosu'

if $DEBUG
  require 'pry'
  puts "Starting in DEBUG Mode"
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
      @kp_sprite.left
    end
    if Gosu::button_down? Gosu::KbRight or Gosu::button_down? Gosu::GpRight then
      @kp_sprite.right
    end
    if Gosu::button_down? Gosu::KbDown or Gosu::button_down? Gosu::GpDown then
      @kp_sprite.down
    end
    if Gosu::button_down? Gosu::KbUp or Gosu::button_down? Gosu::GpUp then
      @kp_sprite.up
    end
  end

  def draw
    @kp_sprite.draw
    @background.draw
  end

  private

  FRAMERATE = 3
  FRAME_WIDTH = 397
  WALK_ANIMATION_FRAMES = 1..-1 #Frame 1 to the end of the sheet
  STANDING_FRAME = 0
  def generate_kp_sprite
    left_walk = Animation.new(ResourceManager::load_from_sheet("kp_left.png", FRAME_WIDTH, WALK_ANIMATION_FRAMES), FRAMERATE)
    right_walk = Animation.new(ResourceManager::load_from_sheet("kp_right.png", FRAME_WIDTH, WALK_ANIMATION_FRAMES), FRAMERATE)
    up_walk = Animation.new(ResourceManager::load_from_sheet("kp_up.png", FRAME_WIDTH, WALK_ANIMATION_FRAMES), FRAMERATE)
    down_walk = Animation.new(ResourceManager::load_from_sheet("kp_down.png", FRAME_WIDTH, WALK_ANIMATION_FRAMES), FRAMERATE)

    left_stand = ResourceManager::load_from_sheet("kp_left.png", FRAME_WIDTH, STANDING_FRAME)
    right_stand = ResourceManager::load_from_sheet("kp_right.png", FRAME_WIDTH, STANDING_FRAME)
    up_stand = ResourceManager::load_from_sheet("kp_up.png", FRAME_WIDTH, STANDING_FRAME)
    down_stand = ResourceManager::load_from_sheet("kp_down.png", FRAME_WIDTH, STANDING_FRAME)

    return Sprite.new(up_walk, down_walk, left_walk, right_walk,
                      up_stand, down_stand, left_stand, right_stand)
  end
end

class ResourceManager
  RESOURCES_PATH="../resources"

  # Depreciated
  warn "[DEPRECIATION] use load_from_sheet instead"
  def self.load_animation(filename, width, height)
    frames = Gosu::Image::load_tiles("#{RESOURCES_PATH}/images/#{filename}", width, height)
    if(!frames.empty?)
      return frames
    else
      raise IOError, "File not Found: #{filename} (#{RESOURCES_PATH}/images/#{filename})"
    end
  end

  ##
  # Loads a certain number of frames from a given
  def self.load_from_sheet(filename, width, frame_range, height: -1)
    frames = Gosu::Image::load_tiles("#{RESOURCES_PATH}/images/#{filename}", width, height)
    if(!frames.empty?)
      return frames[frame_range]
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
  def initialize(frames, framerate)
    @frames = frames
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
  def initialize(walk_up, walk_down, walk_left, walk_right,
                stand_up, stand_down, stand_left, stand_right)
    @pos_x = @pos_y = 0
    @step_size = 10
    @previous_state = :stand_down
    @current_state = :stand_down

    @animations = { :walk_up => walk_up,
                    :walk_down => walk_down,
                    :walk_left=> walk_left,
                    :walk_right=> walk_right,
                    :stand_up=> stand_up,
                    :stand_down => stand_down,
                    :stand_left => stand_left,
                    :stand_right => stand_right
                  }
  end

  def state state
    @current_state = state
  end

  def warp(x, y)
    @pos_x = x;
    @pos_y = y;
  end

  def down
    @pos_y += @step_size
    @current_state = :walk_down
  end

  def up
    @pos_y -= @step_size
    @current_state = :walk_up
  end

  def left
    @pos_x -= @step_size
    @current_state = :walk_left
  end

  def right
    @pos_x += @step_size
    @current_state = :walk_right
  end

  def draw
    @animations[@current_state].draw(@pos_x, @pos_y, ZOrder::Sprites)
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
