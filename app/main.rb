class Game
  attr_gtk

  def initialize
    @camera_x_offset = 0
    @camera_y_offset = 0
    @camera_trauma = 0
    # @room_number = Numeric.rand(0 .. 1023)
    @room_number = 0x0153
    @room_rows = 45 # 720 / 16
    @room_cols = 80 # 1280 / 16
    @segment_height = 16 * 12 + 2 * 16
    @segment_width = 16 * 14 + 2 * 16
    @stuff_to_render = []
  end

  def tick
    game_input
    game_calc
    game_render
  end

  def game_input
    if inputs.mouse.click
      @camera_trauma = 0.5
    end
  end

  def game_calc
  end

  def game_render
    outputs.background_color = [0, 0, 0]
    outputs[:room].w = Grid.w
    outputs[:room].h = Grid.h
    outputs[:room].background_color = [0, 0, 0]

    @room_number = Numeric.rand(0 .. 1023) if Kernel.tick_count.zmod? 20

    @stuff_to_render.clear
    screenshake
    draw_room
    outputs[:room].primitives << @stuff_to_render

    outputs.primitives << {
      x: @camera_x_offset,
      y: @camera_y_offset,
      w: Grid.w,
      h: Grid.h,
      path: :room,
    }
  end

  def screenshake
    return if @camera_trauma == 0
    next_offset = 200 * @camera_trauma**2
    t = Kernel.tick_count
    @camera_x_offset = (Math.sin(t * 0.5) * next_offset).round
    @camera_y_offset = (Math.cos(t * 0.7) * next_offset).round

    @camera_trauma *= 0.95
    if @camera_trauma < 0.05
      @camera_trauma = 0
      @camera_x_offset = 0
      @camera_y_offset = 0
    end
  end

  # function to draw all the walls for a given room
  def draw_room
    @room_grid ||= Array.new(@room_rows) { Array.new(@room_cols, 0) }
    draw_outer_wall_solids
    draw_inner_wall_solids
  end

  # draw the outermost walls that do not change
  def draw_outer_wall_solids
    draw_wall_segment_solids(x: 3,  y: 4,  dir: :N)
    draw_wall_segment_solids(x: 3,  y: 30, dir: :N)
    draw_wall_segment_solids(x: 78, y: 4,  dir: :N)
    draw_wall_segment_solids(x: 78, y: 30, dir: :N)
    draw_wall_segment_solids(x: 3,  y: 4,  dir: :E)
    draw_wall_segment_solids(x: 3,  y: 43, dir: :E)
    draw_wall_segment_solids(x: 18, y: 4,  dir: :E)
    draw_wall_segment_solids(x: 18, y: 43, dir: :E)
    draw_wall_segment_solids(x: 48, y: 4,  dir: :E)
    draw_wall_segment_solids(x: 48, y: 43, dir: :E)
    draw_wall_segment_solids(x: 63, y: 4,  dir: :E)
    draw_wall_segment_solids(x: 63, y: 43, dir: :E)
  end

  # draw inner walls in room, forming a simple maze with wide corridors
  def draw_inner_wall_solids
    @wall_seed = @room_number
    draw_wall_segment_solids(x: 18, y: 30, dir: get_direction)
    draw_wall_segment_solids(x: 33, y: 30, dir: get_direction)
    draw_wall_segment_solids(x: 48, y: 30, dir: get_direction)
    draw_wall_segment_solids(x: 63, y: 30, dir: get_direction)
    draw_wall_segment_solids(x: 18, y: 17, dir: get_direction)
    draw_wall_segment_solids(x: 33, y: 17, dir: get_direction)
    draw_wall_segment_solids(x: 48, y: 17, dir: get_direction)
    draw_wall_segment_solids(x: 63, y: 17, dir: get_direction)
  end

  # function to draw wall segments, pass in the x, y coordinates
  # and the direction to draw the segment
  def draw_wall_segment_solids(x:, y:, dir:)
    case dir
    when :N
      @stuff_to_render <<  { x: (x - 1) * 16,
                             y: (y - 1) * 16,
                             w: 16,
                             h: @segment_height,
                             path: :solid,
                             r: 10, g: 100, b: 200 }
      14.times do |i|
        @room_grid[ y - 1 + i ][ x - 1 ] = 1
      end
    when :S
      @stuff_to_render <<  { x: (x - 1) * 16,
                             y: ((y - 1) * 16) - @segment_height + 16,
                             w: 16,
                             h: @segment_height,
                             path: :solid,
                             r: 10, g: 100, b: 200 }
      14.times do |i|
        @room_grid[ y + i - 14 ][ x - 1 ] = 1
      end
    when :E
      @stuff_to_render <<  { x: (x - 1) * 16,
                             y: (y - 1) * 16,
                             w: @segment_width,
                             h: 16,
                             path: :solid,
                             r: 10, g: 100, b: 200 }
      16.times do |i|
        @room_grid[ y - 1][ x + i - 1] = 1
      end
    when :W
      @stuff_to_render <<  { x: ((x - 1) * 16) - @segment_width + 16,
                             y: (y - 1) * 16,
                             w: @segment_width,
                             h: 16,
                             path: :solid,
                             r: 10, g: 100, b: 200 }
      16.times do |i|
        @room_grid[ y - 1][ x + i - 16] = 1
      end
    end
  end

  # this is a version of the generation system used in the arcade game berzerk
  # it follows the same patterns as the arcade game following a reset.
  def get_direction
    n1 = 0x7
    n2 = 0x3153
    r1 = (@wall_seed * n1) & 0xFFFF
    r2 = (r1 + n2) & 0xFFFF
    r3 = (r2 * n1) & 0xFFFF
    result = (r3 + n2) & 0xFFFF
    @wall_seed = result
    high_8_bits = (result >> 8) & 0xFF
    low_2_bits = high_8_bits & 0x03

    case low_2_bits
    when 0
      :N
    when 1
      :S
    when 2
      :E
    when 3
      :W
    end
  end
end

def self.boot args
  args.state = {}
end

def self.tick args
  $game ||= Game.new
  $game.args = args
  $game.tick
end

def self.reset args
  $game = nil
end

GTK.disable_framerate_warning!
GTK.reset
