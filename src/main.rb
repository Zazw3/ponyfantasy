require 'gosu'

if $DEBUG
  require 'pry'
  puts "Starting in DEBUG Mode"
end

BACKGROUND_SCALE_FACTOR = 1.2

class GameWindow < Gosu::Window
  Boundries = []

  def initialize
    @previous_buttons = [] #Stores the buttons which were being pressed in the previous tick

    super 1600, 900
    # super 480, 360
    self.caption = "PF"

    @kp_sprite = generate_kp_sprite
    @kp_sprite.warp(4400, 1310)
    @background = Background.new("background_01.png", :fixed_scale_factor=>BACKGROUND_SCALE_FACTOR)
    @camera = Camera.new(@kp_sprite.pos_x - width/2, @kp_sprite.pos_y - height/2)
    @buttons_down = []

    # Boundries.push([ymin, ymax], [[xmin1 xmax1], ...])
    Boundries.push([[0, 430],      [[0, 0]]] )
    Boundries.push([[430, 625],    [[575, 1900]]] )
    Boundries.push([[625, 1120],   [[575, 770],  [1700, 1900]]] )
    Boundries.push([[910, 1120],    [[3592, 4045]]])
    Boundries.push([[1120, 1325],  [[0, 770],    [1700, 4600]] ])
    Boundries.push([[1325, 1205],  [[0,0]]] )
    @kp_sprite.set_bounds(Boundries)
  end

  def button_down (id)
    @buttons_down.push(id)

    case id
    when Gosu::KbLeft, Gosu::GpLeft
      @kp_sprite.state :stand_left
    when Gosu::KbRight, Gosu::GpRight
      @kp_sprite.state :stand_right
    when Gosu::KbDown, Gosu::GpDown
      @kp_sprite.state :stand_down
    when Gosu::KbUp, Gosu::GpUp
      @kp_sprite.state :stand_up
    end
  end

  def button_up (id)
    @buttons_down.delete(id)

    case id
    when Gosu::KbLeft, Gosu::GpLeft
      @kp_sprite.state :stand_left
    when Gosu::KbRight, Gosu::GpRight
      @kp_sprite.state :stand_right
    when Gosu::KbDown, Gosu::GpDown
      @kp_sprite.state :stand_down
    when Gosu::KbUp, Gosu::GpUp
      @kp_sprite.state :stand_up
    else
    end
  end

  def button_pressed(ids)
    ids.each {|id|
      case id
      when Gosu::KbEscape
        close
      when Gosu::KbLeft, Gosu::GpLeft
        @kp_sprite.left
      when Gosu::KbRight, Gosu::GpRight
        @kp_sprite.right
      when Gosu::KbDown, Gosu::GpDown
        @kp_sprite.down
      when Gosu::KbUp, Gosu::GpUp
        @kp_sprite.up
      end
    }
  end

  def update
    button_pressed(@buttons_down)
    @kp_sprite.update


  end

  def draw
    # Camera is locked to kp
    @camera.x, @camera.y = (@kp_sprite.pos_x + @kp_sprite.width/2) - width/2, (@kp_sprite.pos_y + @kp_sprite.height/2) - height/2
    @kp_sprite.draw(@camera)
    @background.draw(@camera)
    # draw_boundries(@camera)
    # draw_kp_box(@camera)
  end

  def draw_boundries(camera)
    Boundries.each{|boundry|
        boundry[1].each{|x_boundry|
            red = Gosu::Color.new(100, 255, 0, 0)
            draw_quad((x_boundry[0]*BACKGROUND_SCALE_FACTOR).to_i-camera.x, (boundry[0][0]*BACKGROUND_SCALE_FACTOR).to_i-camera.y, red,
                      (x_boundry[0]*BACKGROUND_SCALE_FACTOR).to_i-camera.x, (boundry[0][1]*BACKGROUND_SCALE_FACTOR).to_i-camera.y, red,
                      (x_boundry[1]*BACKGROUND_SCALE_FACTOR).to_i-camera.x, (boundry[0][0]*BACKGROUND_SCALE_FACTOR).to_i-camera.y, red,
                      (x_boundry[1]*BACKGROUND_SCALE_FACTOR).to_i-camera.x, (boundry[0][1]*BACKGROUND_SCALE_FACTOR).to_i-camera.y, red,
                      ZOrder::Debug_Overlays)
        }
    }
  end

  def draw_kp_box(camera)
    grn = Gosu::Color.new(50, 0, 255, 0)
    draw_quad(@kp_sprite.pos_x-camera.x, @kp_sprite.pos_y-camera.y, grn,
              @kp_sprite.pos_x + @kp_sprite.width-camera.x, @kp_sprite.pos_y-camera.y, grn,
              @kp_sprite.pos_x + @kp_sprite.width-camera.x, @kp_sprite.pos_y + @kp_sprite.height-camera.y, grn,
              @kp_sprite.pos_x-camera.x, @kp_sprite.pos_y + @kp_sprite.height-camera.y, grn,
              ZOrder::Debug_Overlays)
  end

  private

  FRAMERATE = 3
  FRAME_WIDTH = 397
  WALK_ANIMATION_FRAMES = 1..-1 #Frame 1 to the end of the sheet
  STANDING_FRAME = 0
  KP_SPRITE_SCALE = 0.5
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
                      up_stand, down_stand, left_stand, right_stand,
                      :fixed_scale_factor => KP_SPRITE_SCALE)
  end
end

class ResourceManager
  RESOURCES_PATH="../resources"

  # Depreciated
  warn "[DEPRECIATION] use load_from_sheet instead"
  def self.load_animation(filename, width, height)
    frames = Gosu::Image::load_tiles("#{RESOURCES_PATH}/images/#{filename}", width, height)
    if(!frames.empty)
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
  BG, Sprites, Debug_Overlays = *0..2
end
class Animation
  def initialize(frames, framerate)
    @frames = frames
    @current_frame = 0
    @previous_time = Time.new
    @framerate = framerate
  end

  def width
    @frames[0].width
  end

  def height
    @frames[0].height
  end

  def setFrame (frame)
    @current_frame = frame
  end

  def draw(x, y, z, scale_x = 1, scale_y = 1, color = 0xff_ffffff, mode = :default)
    current_time = Time.new
    if(current_time.to_f - @previous_time.to_f  >= 1.to_f/@framerate)
      @previous_time = current_time
      if(@current_frame >= @frames.length-1)
        @current_frame = 0
      else
        @current_frame += 1
      end
    end
    @frames[@current_frame].draw(x, y, z, scale_x, scale_y, color, mode)

  end
end

class Sprite
  attr_reader :pos_x, :pos_y,
              :width, :height

  def initialize(walk_up, walk_down, walk_left, walk_right,
                stand_up, stand_down, stand_left, stand_right,
                fixed_scale_factor: 1)
    @pos_x = @pos_y = 0
    @step_size = 10
    @scale_factor = fixed_scale_factor
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

  def set_bounds(boundries)
    @boundries = boundries
  end

  def state state
    @current_state = state
  end

  def warp(x, y)
    @pos_x = x;
    @pos_y = y;
  end

  def down

    if(within_bounds(@boundries, @pos_x + width/3, @pos_y + @step_size + height))
      @pos_y += @step_size
      @current_state = :walk_down
    end
  end

  def up
    # height is 3/4 to allow kp sprite to use the fullmost of the path, the bottom 1/4 of the
    # sprite is approximately appropriate ()Except when she's traveling downwards
    if (within_bounds(@boundries, @pos_x+width/3, @pos_y - @step_size+height*3/4))
      @pos_y -= @step_size
      @current_state = :walk_up
    end
  end

  def left
    if(within_bounds(@boundries, @pos_x-@step_size+width/3, @pos_y+height*3/4))
      @pos_x -= @step_size
      @current_state = :walk_left
    end
  end

  def right
    if (within_bounds(@boundries, @pos_x+@step_size+width/3, @pos_y+height*3/4))
      @pos_x += @step_size
      @current_state = :walk_right
    end
  end

  def width
    @animations[@current_state].width * @scale_factor
  end

  def height
    @animations[@current_state].height * @scale_factor
  end

  def update

  end

  def within_bounds(boundries, x, y)
    is_within_bounds = false
    boundries.each{|boundry|
      if y.between?(boundry[0][0]*BACKGROUND_SCALE_FACTOR, boundry[0][1]*BACKGROUND_SCALE_FACTOR)
        boundry[1].each{|x_boundry|
          if x.between?(x_boundry[0]*BACKGROUND_SCALE_FACTOR, x_boundry[1]*BACKGROUND_SCALE_FACTOR)
            #Within Bounds
            is_within_bounds = true
          end
        }
      end
    }
    return is_within_bounds
    # if is_within_bounds
    #   puts "Within Bounds #{x}, #{y}"
    # else
    #   puts "Out of Bounds #{x}, #{y}"
    # end
  end

  def draw(camera)
    @animations[@current_state].draw(@pos_x-camera.x, @pos_y-camera.y, ZOrder::Sprites,
                                    @scale_factor, @scale_factor)
  end
end

class Background
  def initialize(filename, fixed_scale_factor: 1)
    @pos_x = @pos_y = 0;
    @scale_factor = fixed_scale_factor
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

  def draw(camera)
    @image.draw(@pos_x-camera.x, @pos_y-camera.y, ZOrder::BG, @scale_factor, @scale_factor)
  end
end

class Camera
  def initialize(x, y)
    @x, @y = x, y
  end

  attr_accessor :x, :y
end


if __FILE__ == $0
  window = GameWindow.new
  window.show
end
