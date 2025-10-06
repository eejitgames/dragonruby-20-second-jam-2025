class Game
  attr_gtk

  def initialize
    @camera_x_offset = 0
    @camera_y_offset = 0
    @camera_trauma = 0
    # @room_number = Numeric.rand(0 .. 1023)
    # @room_number = 0x0153
    @room_number = -1 # this is an empty blank room
    @room_rows = 45 # 720 / 16
    @room_cols = 80 # 1280 / 16
    @segment_height = 16 * 12 + 2 * 16
    @segment_width = 16 * 14 + 2 * 16
    @new_room_needed = true
    @creating_tiles = nil
    @thumbnail_index = 0
    @stuff_to_render = []
    @waypoints = []
  end

  def tick
    game_input
    game_calc
    game_render
  end

  def game_input
    if inputs.mouse.click
      @camera_trauma = 0.5
      x = inputs.mouse.click.point.x
      y = inputs.mouse.click.point.y
      @waypoints << { x: x, y: y }
      @redraw_room = true
    end
  end

  def game_calc
    # create_thumbnails_if_needed
  end

  def game_render
    outputs.background_color = [0, 0, 0]
# =begin
    if Kernel.tick_count.zmod? 60
      @room_number = Numeric.rand(0 .. 1023)
      @redraw_room = true
      @room_grid = nil
    end
# =end
    screenshake
    update_room_and_waypoints

    outputs.primitives << {
      x: @camera_x_offset,
      y: @camera_y_offset,
      w: Grid.w,
      h: Grid.h,
      path: :room,
    }
  end

  def update_room_and_waypoints
    return unless @redraw_room
    outputs[:room].w = 1280
    outputs[:room].h = 720
    outputs[:room].background_color = [0, 0, 0]

    # putz "drawing a new room #{Kernel.tick_count}"
    @stuff_to_render.clear
    @room_grid ||= Array.new(@room_rows) { Array.new(@room_cols, 0) }
    unless @room_number == -1
      # maze related updates
      update_outer_wall_solids
      update_inner_wall_solids
      update_outer_wall_sprites
      update_inner_wall_sprites
      update_wall_junction_sprites
      outputs[:room].primitives << @stuff_to_render
    end
    @new_room_needed = nil

    # updates for waypoints
    @stuff_to_render << @waypoints.map_with_index do |wp, i|
      { x: wp[:x], y: wp[:y], text: "#{i + 1}", size_enum: 20,
        anchor_x: 0.5, anchor_y: 0.5, r: 0, g: 200, b: 0 }
    end

    @stuff_to_render << @waypoints.map do |wp|
      { x: wp[:x], y: wp[:y], w: 10, h: 10,
        anchor_x: 0.5, anchor_y: 0.5, path: :solid, r: 200, g: 0, b: 0 }
    end
    outputs[:room].primitives << @stuff_to_render
  end

  def screenshake
    return if @camera_trauma == 0
    next_offset = 100 * @camera_trauma**2
    t = Kernel.tick_count
    @camera_x_offset = (Math.sin(t * 0.5) * next_offset)
    @camera_y_offset = (Math.cos(t * 0.7) * next_offset)

    @camera_trauma *= 0.95
    if @camera_trauma < 0.05
      @camera_trauma = 0
      @camera_x_offset = 0
      @camera_y_offset = 0
    end
  end

  def update_wall_junction_sprites
    @stuff_to_render << { x: 31 * 16, y: 41 * 16, w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x: 32, y: 42)}.png" }
    @stuff_to_render << { x: 46 * 16, y: 41 * 16, w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x: 47, y: 42)}.png" }
    @stuff_to_render << { x: 1 * 16 , y: 15 * 16, w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x:  2, y: 16)}.png" }
    @stuff_to_render << { x: 1 * 16 , y: 28 * 16, w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x:  2, y: 29)}.png" }

    @stuff_to_render << { x: 16 * 16, y:  2 * 16, w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x: 17, y:  3)}.png" }
    @stuff_to_render << { x: 16 * 16, y: 41 * 16, w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x: 17, y: 42)}.png" }
    @stuff_to_render << { x: 61 * 16, y:  2 * 16, w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x: 62, y:  3)}.png" }
    @stuff_to_render << { x: 61 * 16, y: 41 * 16, w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x: 62, y: 42)}.png" }

    @stuff_to_render << { x: 31 * 16, y: 15 * 16, w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x: 32, y: 16)}.png" }
    @stuff_to_render << { x: 46 * 16, y: 15 * 16, w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x: 47, y: 16)}.png" }
    @stuff_to_render << { x: 61 * 16, y: 15 * 16, w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x: 62, y: 16)}.png" }
    @stuff_to_render << { x: 16 * 16, y: 15 * 16, w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x: 17, y: 16)}.png" }
    @stuff_to_render << { x: 31 * 16, y: 28 * 16, w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x: 32, y: 29)}.png" }
    @stuff_to_render << { x: 46 * 16, y: 28 * 16, w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x: 47, y: 29)}.png" }
    @stuff_to_render << { x: 61 * 16, y: 28 * 16, w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x: 62, y: 29)}.png" }
    @stuff_to_render << { x: 16 * 16, y: 28 * 16, w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x: 17, y: 29)}.png" }

    @stuff_to_render << { x: 76 * 16, y: 15 * 16, w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x: 77, y: 16)}.png" }
    @stuff_to_render << { x: 76 * 16, y: 28 * 16, w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x: 77, y: 29)}.png" }
    @stuff_to_render << { x: 31 * 16, y:  2 * 16, w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x: 32, y:  3)}.png" }
    @stuff_to_render << { x: 46 * 16, y:  2 * 16, w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x: 47, y:  3)}.png" }
  end

  # draw inner walls in room, forming a simple maze with wide corridors
  def update_inner_wall_sprites
    @wall_seed = @room_number
    draw_wall_segment_sprites(x: 18, y: 30, dir: get_direction)
    draw_wall_segment_sprites(x: 33, y: 30, dir: get_direction)
    draw_wall_segment_sprites(x: 48, y: 30, dir: get_direction)
    draw_wall_segment_sprites(x: 63, y: 30, dir: get_direction)
    draw_wall_segment_sprites(x: 18, y: 17, dir: get_direction)
    draw_wall_segment_sprites(x: 33, y: 17, dir: get_direction)
    draw_wall_segment_sprites(x: 48, y: 17, dir: get_direction)
    draw_wall_segment_sprites(x: 63, y: 17, dir: get_direction)
  end

  # draw the outermost walls that do not change
  def update_outer_wall_solids
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
  def update_inner_wall_solids
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

  # draw the outermost walls that do not change
  def update_outer_wall_sprites
    draw_wall_segment_sprites(x: 3,  y: 4,  dir: :N)
    draw_wall_segment_sprites(x: 3,  y: 30, dir: :N)
    draw_wall_segment_sprites(x: 78, y: 4,  dir: :N)
    draw_wall_segment_sprites(x: 78, y: 30, dir: :N)
    draw_wall_segment_sprites(x: 3,  y: 4,  dir: :E)
    draw_wall_segment_sprites(x: 3,  y: 43, dir: :E)
    draw_wall_segment_sprites(x: 18, y: 4,  dir: :E)
    draw_wall_segment_sprites(x: 18, y: 43, dir: :E)
    draw_wall_segment_sprites(x: 48, y: 4,  dir: :E)
    draw_wall_segment_sprites(x: 48, y: 43, dir: :E)
    draw_wall_segment_sprites(x: 63, y: 4,  dir: :E)
    draw_wall_segment_sprites(x: 63, y: 43, dir: :E)

    @stuff_to_render <<  { x: 1 * 16,  y: 2 * 16, w: 48, h: 48, path: "sprites/walls/wall_5.png" }
    @stuff_to_render <<  { x: 1 * 16,  y: 42 * 16 - 16, w: 48, h: 48, path: "sprites/walls/wall_12.png" }
    @stuff_to_render <<  { x: 76 * 16, y: 42 * 16 - 16, w: 48, h: 48, path: "sprites/walls/wall_10.png" }
    @stuff_to_render <<  { x: 76 * 16, y: 2 * 16, w: 48, h: 48, path: "sprites/walls/wall_3.png" }

    @stuff_to_render << { x: 31 * 16,  y: 2 * 16,  w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x: 32, y: 3)}.png" }
    @stuff_to_render << { x: 31 * 16,  y: 41 * 16, w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x: 32, y: 42)}.png" }
    @stuff_to_render << { x: 46 * 16,  y: 2 * 16,  w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x: 47, y: 3)}.png" }
    @stuff_to_render << { x: 46 * 16,  y: 41 * 16, w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x: 47, y: 42)}.png" }

    @stuff_to_render << { x: 16 * 16,  y: 2 * 16,  w: 48, h: 48, path: "sprites/walls/wall_6.png" }
    @stuff_to_render << { x: 16 * 16,  y: 41 * 16, w: 48, h: 48, path: "sprites/walls/wall_6.png" }
    @stuff_to_render << { x: 61 * 16,  y: 2 * 16,  w: 48, h: 48, path: "sprites/walls/wall_6.png" }
    @stuff_to_render << { x: 61 * 16,  y: 41 * 16, w: 48, h: 48, path: "sprites/walls/wall_6.png" }

    @stuff_to_render << { x: 1 * 16,   y: 15 * 16, w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x: 2, y: 16)}.png" }
    @stuff_to_render << { x: 1 * 16,   y: 28 * 16, w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x: 2, y: 29)}.png" }
    @stuff_to_render << { x: 76 * 16,  y: 15 * 16, w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x: 77, y: 16)}.png" }
    @stuff_to_render << { x: 76 * 16,  y: 28 * 16, w: 48, h: 48, path: "sprites/walls/wall_#{choose_junction_sprite(x: 77, y: 29)}.png" }
  end

  def draw_wall_segment_sprites(x:, y:, dir:)
    case dir
    when :N
      4.times do |i|
        @stuff_to_render <<  { x: (x - 2) * 16,
                               y: y * 16 + (i * 48),
                               w: 48,
                               h: 48,
                               path: "sprites/walls/wall_9.png" }
      end
    when :S
      4.times do |i|
        @stuff_to_render <<  { x: (x - 2) * 16,
                               y: y * 16 + (i * 48) - @segment_height + 16,
                               w: 48,
                               h: 48,
                               path: "sprites/walls/wall_9.png" }
      end
    when :E
      4.times do |i|
        @stuff_to_render <<  { x: (x + 1) * 16 + (i * 48),
                               y: (y - 2) * 16,
                               w: 48,
                               h: 48,
                               path: "sprites/walls/wall_6.png" }
      end
    when :W
      4.times do |i|
        @stuff_to_render <<  { x: (x + 1) * 16 + (i * 48) - @segment_width + 16,
                               y: (y - 2) * 16,
                               w: 48,
                               h: 48,
                               path: "sprites/walls/wall_6.png" }
      end
    end
  end

  # we want to check the game grid coordinates at x: 3, y: 4,
  # this is at x: 2, y: 3 in 2d array, since 0, 0 is bottom left corner
  def choose_junction_sprite(x:, y:)
    n = (@room_grid[y + 1][x] == 1) ? 1 : 0
    s = (@room_grid[y - 1][x] == 1) ? 1 : 0
    e = (@room_grid[y][x + 1] == 1) ? 1 : 0
    w = (@room_grid[y][x - 1] == 1) ? 1 : 0
    # return autotile bits in decimal form
    "#{s}#{e}#{w}#{n}".to_i(2)
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

  def create_thumbnails_if_needed
    # pressing enter will start the thumbnail creation process
    if inputs.keyboard.key_down.enter && !@creating_tiles
      @displaying_tiles = false
      @creating_tiles = true
      @thumbnail_clock = 0
    end

    if !GTK.stat_file("sprites/room-1023.png") && !@creating_tiles
      args.state.displaying_tiles = false
      args.outputs.labels << {
        x: 720,
        y: 360,
        text: "Press enter to generate map thumbnails",
        alignment_enum: 1,
        vertical_alignment_enum: 1,
        r: 200, g: 200, b: 200
      }
    elsif !args.state.creating_tiles
      @displaying_tiles = true
    end

    # the thumbnail creation process renders a room
    # to the screen and takes a screenshot of it every half second
    # until all the thumbnails are generated.
    if @creating_tiles
      # select a room to render
      @room_number = @thumbnail_index
      @redraw_room = true

      # determine tile file name
      thumbnail_path = "sprites/thumbnails/room-#{@room_number}.png"

      putz "Generating #{thumbnail_path}"

      # take a screenshot on frames divisible by 29
      if @thumbnail_clock.zmod?(29)
        outputs.screenshots << {
          x: 0,
          y: 0,
          w: Grid.w,
          h: Grid.h,
          path: thumbnail_path,
          a: 255
        }
      end

      # increment tile to render on frames divisible by 30 (half a second)
      # (one frame is allotted to take screenshot)
      if @thumbnail_clock.zmod?(30)
        @thumbnail_index +=1
        # once all of tile tiles are created, begin displaying map
        if @thumbnail_index > 1023
          @creating_tiles = false
          @displaying_tiles = true
          @room_number = -1
        end
      end
      @thumbnail_clock +=1
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
