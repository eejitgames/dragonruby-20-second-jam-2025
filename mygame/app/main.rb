class Game
  attr_gtk

  def initialize
    # @room_number = Numeric.rand(0 .. 1023)
    @room_number = 0x0153
    @room_rows = 45 # 720 / 16
    @room_cols = 80 # 1280 / 16
    @segment_height = 16 * 12 + 2 * 16
    @segment_width = 16 * 14 + 2 * 16
  end

  def tick
    outputs.background_color = [ 200, 200, 200 ]
    draw_room
  end

  # function to draw all the walls for a given room
  def draw_room
    @room_grid ||= Array.new(@room_rows) { Array.new(@room_cols, 0) }
    draw_outer_wall_solids
    draw_inner_wall_solids
    # draw_outer_wall_sprites
    # draw_inner_wall_sprites
    # draw_wall_junctions_sprites
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

  # function to draw wall segments, pass in the x, y coordinates, and the direction to draw the segment
  def draw_wall_segment_solids(x:, y:, dir:)
    case dir
    when :N
      outputs.solids   <<  { x: (x - 1) * 16, y: (y - 1) * 16, w: 16, h: @segment_height, r: 10, g: 100, b: 200 }
      14.times do |i|
        @room_grid[ y - 1 + i ][ x - 1 ] = 1
      end
    when :S
      outputs.solids   <<  { x: (x - 1) * 16, y: ((y - 1) * 16) - @segment_height + 16, w: 16, h: @segment_height, r: 10, g: 100, b: 200 }
      14.times do |i|
        @room_grid[ y + i - 14 ][ x - 1 ] = 1
      end
    when :E
      outputs.solids   <<  { x: (x - 1) * 16, y: (y - 1) * 16, w: @segment_width, h: 16, r: 10, g: 100, b: 200 }
      16.times do |i|
        @room_grid[ y - 1][ x + i - 1] = 1
      end
    when :W
      outputs.solids   <<  { x: ((x - 1) * 16) - @segment_width + 16, y: (y - 1) * 16, w: @segment_width, h: 16, r: 10, g: 100, b: 200 }
      16.times do |i|
        @room_grid[ y - 1][ x + i - 16] = 1
      end
    end
  end

  # this is a version of the generation system used in the arcade game berzerk - it follows the same patterns as the arcade game following a reset.
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

GTK.reset
