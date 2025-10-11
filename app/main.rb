# Logical canvas width and height
WIDTH = 1280
HEIGHT = 720

# Game screen dimensions
GAME_WIDTH = 320
GAME_HEIGHT = 180

# Determine best fit zoom level
ZOOM_WIDTH = (WIDTH / GAME_WIDTH).floor
ZOOM_HEIGHT = (HEIGHT / GAME_HEIGHT).floor
ZOOM = [ZOOM_WIDTH, ZOOM_HEIGHT].min

# Compute the offset to center the game screen
OFFSET_X = (WIDTH - GAME_WIDTH * ZOOM) / 2
OFFSET_Y = (HEIGHT - GAME_HEIGHT * ZOOM) / 2

# Compute the scaled dimensions of the game screen
ZOOMED_WIDTH = GAME_WIDTH * ZOOM
ZOOMED_HEIGHT = GAME_HEIGHT * ZOOM

SF = 4  # SCALING_FACTOR: 4 for 320x180, 16 for 1280x720
WS = 12 # WALL_SIZE: 12 for 320x180, 48 for 1280x720

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
    @segment_height = SF * 12 + 2 * SF
    @segment_width = SF * 14 + 2 * SF
    @thumbnail_index = 0
    @redraw_room = true
    @redraw_hud = true
    @stuff_to_render = []
    @hud_stuff_to_render = []
    @waypoints = []
    @current_scene = :title_scene
    # @spawn_point = { x: 8.5 * 16, y: [ 8.5, 21.5, 34.5 ].sample * 16 }
    # @exit_point = { x: 68.5 * 16, y: [ 8.5, 21.5, 34.5 ].sample * 16 }
    @spawn_point = { x: 8.5 * 4, y: 23 * 4 }
    @exit_point = { x: 69 * 16, y: 23.5 * 16 }
    @player = {
      x: @spawn_point.x,
      y: @spawn_point.y,
      w: 12,
      h: 12,
      path: :solid,
      anchor_x: 0.5,
      anchor_y: 0.5,
      r: 0, g: 200, b: 0,
      speed: 0.8
    }
  end

  def tick
    scene_manager
  end

  def scene_manager
    current_scene = @current_scene

    case current_scene
    when :title_scene
      tick_title_scene
    when :game_scene
      tick_game_scene
    when :game_over_scene
      tick_game_over_scene
    end

    if @current_scene != current_scene
      raise "Scene was changed incorrectly. Set @next_scene to change scenes."
    end

    if @next_scene
      @current_scene = @next_scene
      @next_scene = nil
    end
  end

  def tick_title_scene
    outputs.labels << {
      x: 640,
      y: 460,
      text: "A MAZE IN TIME",
      alignment_enum: 1
    }

    outputs.labels << {
      x: 640,
      y: 360,
      text: "(click to start the game)",
      alignment_enum: 1
    }

    if inputs.mouse.click
      @next_scene = :game_scene
    end
  end

  def tick_game_scene
    game_input
    game_calc
    game_render
    # temporary logic to transition to game over scene
    if inputs.keyboard.key_down.k
      @next_scene = :game_over_scene
    end
  end

  def tick_game_over_scene
    outputs.labels << {
      x: 640,
      y: 460,
      text: "Game Over",
      alignment_enum: 1
    }

    outputs.labels << {
      x: 640,
      y: 360,
      text: "(click to go to title)",
      alignment_enum: 1
    }

    if inputs.mouse.click
      GTK.reset_next_tick
    end
  end

  def game_input
    if inputs.mouse.click
      # @camera_trauma = 0.5
      # x = inputs.mouse.click.point.x
      # y = inputs.mouse.click.point.y
      x = (inputs.mouse.x - OFFSET_X).idiv(ZOOM)
      y = (inputs.mouse.y - OFFSET_Y).idiv(ZOOM)
      @waypoints << { x: x, y: y }
      @redraw_room = true
    end
  end

  def game_calc
    # create_thumbnails_if_needed
    move_player
  end

  def game_render
    outputs.background_color = [0, 0, 0]
=begin
    if Kernel.tick_count.zmod? 60
      @room_number = Numeric.rand(0 .. 1023)
      @redraw_room = true
      @room_grid = nil
    end
=end
    screenshake
    update_room_and_waypoints
    update_exit
    update_player
    update_hud

    # render the game scaled to fit the screen
    outputs.primitives << {
      x: @camera_x_offset,
      y: @camera_y_offset,
      w: WIDTH,
      h: HEIGHT,
      path: :room,
    }

    # render the game scaled to fit the screen
    outputs.primitives << {
      x: @camera_x_offset,
      y: @camera_y_offset,
      w: WIDTH,
      h: HEIGHT,
      path: :hud,
    }
  end

  def move_player
    return if @waypoints.empty?

    wp = @waypoints.first
    dx = wp[:x] - @player.x
    dy = wp[:y] - @player.y
    dist = Math.sqrt(dx * dx + dy * dy)

    # we've reached a waypoint
    if dist < @player.speed
      @player.x, @player.y = wp[:x], wp[:y]
      @waypoints.shift
    else
      # move towards the waypoint
      @player.x += (dx / dist) * @player.speed
      @player.y += (dy / dist) * @player.speed
    end
  end

  def update_player
    outputs[:room].primitives << @player
  end

  def update_exit
    outputs[:hud].primitives << {
      x: @exit_point[:x], y: @exit_point[:y],
      text: "EXIT", size_enum: 5, r: 0, g: 200, b: 0 }

    outputs[:hud].primitives << {
      x: @exit_point[:x], y: @exit_point[:y],
      w: 59, h: 27, anchor_y: 1, r: 200, g: 0, b: 0 }.border!
  end

  def update_hud
    return unless @redraw_hud
    # define a render target that represents the game screen
    outputs[:hud].w = WIDTH
    outputs[:hud].h = HEIGHT
    outputs[:hud].background_color = [0, 0, 0, 0]

    @hud_stuff_to_render.clear
    @hud_stuff_to_render << @waypoints.map_with_index do |wp, i|
      { x: wp[:x] * SF, y: wp[:y] * SF, text: "#{i + 1}", size_enum: 20,
        anchor_x: 0.5, anchor_y: 0.5, r: 0, g: 200, b: 0 }
    end

    outputs[:hud].primitives << @hud_stuff_to_render
  end

  def update_room_and_waypoints
    return unless @redraw_room
    outputs[:room].w = GAME_WIDTH
    outputs[:room].h = GAME_HEIGHT
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

    # updates for waypoints
    @stuff_to_render << @waypoints.map do |wp|
      { x: wp[:x], y: wp[:y], w: SF, h: SF,
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
    @stuff_to_render << { x: 31 * SF, y: 41 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x: 32, y: 42)}.png" }
    @stuff_to_render << { x: 46 * SF, y: 41 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x: 47, y: 42)}.png" }
    @stuff_to_render << { x:  1 * SF, y: 15 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x:  2, y: 16)}.png" }
    @stuff_to_render << { x:  1 * SF, y: 28 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x:  2, y: 29)}.png" }

    @stuff_to_render << { x: 16 * SF, y:  2 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x: 17, y:  3)}.png" }
    @stuff_to_render << { x: 16 * SF, y: 41 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x: 17, y: 42)}.png" }
    @stuff_to_render << { x: 61 * SF, y:  2 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x: 62, y:  3)}.png" }
    @stuff_to_render << { x: 61 * SF, y: 41 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x: 62, y: 42)}.png" }

    @stuff_to_render << { x: 31 * SF, y: 15 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x: 32, y: 16)}.png" }
    @stuff_to_render << { x: 46 * SF, y: 15 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x: 47, y: 16)}.png" }
    @stuff_to_render << { x: 61 * SF, y: 15 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x: 62, y: 16)}.png" }
    @stuff_to_render << { x: 16 * SF, y: 15 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x: 17, y: 16)}.png" }
    @stuff_to_render << { x: 31 * SF, y: 28 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x: 32, y: 29)}.png" }
    @stuff_to_render << { x: 46 * SF, y: 28 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x: 47, y: 29)}.png" }
    @stuff_to_render << { x: 61 * SF, y: 28 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x: 62, y: 29)}.png" }
    @stuff_to_render << { x: 16 * SF, y: 28 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x: 17, y: 29)}.png" }

    @stuff_to_render << { x: 76 * SF, y: 15 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x: 77, y: 16)}.png" }
    @stuff_to_render << { x: 76 * SF, y: 28 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x: 77, y: 29)}.png" }
    @stuff_to_render << { x: 31 * SF, y:  2 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x: 32, y:  3)}.png" }
    @stuff_to_render << { x: 46 * SF, y:  2 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x: 47, y:  3)}.png" }
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

    @stuff_to_render << { x:  1 * SF, y:  2 * SF, w: WS, h: WS, path: "sprites/walls/wall_5.png" }
    @stuff_to_render << { x:  1 * SF, y: 42 * SF - SF, w: WS, h: WS, path: "sprites/walls/wall_12.png" }
    @stuff_to_render << { x: 76 * SF, y: 42 * SF - SF, w: WS, h: WS, path: "sprites/walls/wall_10.png" }
    @stuff_to_render << { x: 76 * SF, y:  2 * SF, w: WS, h: WS, path: "sprites/walls/wall_3.png" }

    @stuff_to_render << { x: 31 * SF, y:  2 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x: 32, y: 3)}.png" }
    @stuff_to_render << { x: 31 * SF, y: 41 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x: 32, y: 42)}.png" }
    @stuff_to_render << { x: 46 * SF, y:  2 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x: 47, y: 3)}.png" }
    @stuff_to_render << { x: 46 * SF, y: 41 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x: 47, y: 42)}.png" }

    @stuff_to_render << { x: 16 * SF, y:  2 * SF, w: WS, h: WS, path: "sprites/walls/wall_6.png" }
    @stuff_to_render << { x: 16 * SF, y: 41 * SF, w: WS, h: WS, path: "sprites/walls/wall_6.png" }
    @stuff_to_render << { x: 61 * SF, y:  2 * SF, w: WS, h: WS, path: "sprites/walls/wall_6.png" }
    @stuff_to_render << { x: 61 * SF, y: 41 * SF, w: WS, h: WS, path: "sprites/walls/wall_6.png" }

    @stuff_to_render << { x:  1 * SF, y: 15 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x: 2, y: 16)}.png" }
    @stuff_to_render << { x:  1 * SF, y: 28 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x: 2, y: 29)}.png" }
    @stuff_to_render << { x: 76 * SF, y: 15 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x: 77, y: 16)}.png" }
    @stuff_to_render << { x: 76 * SF, y: 28 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{choose_junction_sprite(x: 77, y: 29)}.png" }
  end

  def draw_wall_segment_sprites(x:, y:, dir:)
    case dir
    when :N
      4.times do |i|
        @stuff_to_render <<  { x: (x - 2) * SF,
                               y: y * SF + (i * WS),
                               w: WS,
                               h: WS,
                               path: "sprites/walls/wall_9.png" }
      end
    when :S
      4.times do |i|
        @stuff_to_render <<  { x: (x - 2) * SF,
                               y: y * SF + (i * WS) - @segment_height + SF,
                               w: WS,
                               h: WS,
                               path: "sprites/walls/wall_9.png" }
      end
    when :E
      4.times do |i|
        @stuff_to_render <<  { x: (x + 1) * SF + (i * WS),
                               y: (y - 2) * SF,
                               w: WS,
                               h: WS,
                               path: "sprites/walls/wall_6.png" }
      end
    when :W
      4.times do |i|
        @stuff_to_render <<  { x: (x + 1) * SF + (i * WS) - @segment_width + SF,
                               y: (y - 2) * SF,
                               w: WS,
                               h: WS,
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
      @stuff_to_render <<  { x: (x - 1) * SF,
                             y: (y - 1) * SF,
                             w: SF,
                             h: @segment_height,
                             path: :solid,
                             r: 10, g: 100, b: 200 }
      14.times do |i|
        @room_grid[ y - 1 + i ][ x - 1 ] = 1
      end
    when :S
      @stuff_to_render <<  { x: (x - 1) * SF,
                             y: ((y - 1) * SF) - @segment_height + SF,
                             w: SF,
                             h: @segment_height,
                             path: :solid,
                             r: 10, g: 100, b: 200 }
      14.times do |i|
        @room_grid[ y + i - 14 ][ x - 1 ] = 1
      end
    when :E
      @stuff_to_render <<  { x: (x - 1) * SF,
                             y: (y - 1) * SF,
                             w: @segment_width,
                             h: SF,
                             path: :solid,
                             r: 10, g: 100, b: 200 }
      16.times do |i|
        @room_grid[ y - 1][ x + i - 1] = 1
      end
    when :W
      @stuff_to_render <<  { x: ((x - 1) * SF) - @segment_width + SF,
                             y: (y - 1) * SF,
                             w: @segment_width,
                             h: SF,
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
      @displaying_tiles = false
      outputs.labels << {
        x: 720,
        y: 360,
        text: "Press enter to generate map thumbnails",
        alignment_enum: 1,
        vertical_alignment_enum: 1,
        r: 200, g: 200, b: 200
      }
    elsif !@creating_tiles
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
