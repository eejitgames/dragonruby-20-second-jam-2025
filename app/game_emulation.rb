module GameEmulation
  # Logical canvas width and height
  WIDTH = 1280
  HEIGHT = 720

  # Game screen dimensions, 320x180 - integer scaling is best
  # 320x180 is the minimum expected virtual game resolution
  GAME_WIDTH  = 320
  GAME_HEIGHT = 180

  # Determine best fit zoom level
  ZOOM_WIDTH =  ( WIDTH / GAME_WIDTH ).floor
  ZOOM_HEIGHT = ( HEIGHT / GAME_HEIGHT ).floor
  ZOOM = [ ZOOM_WIDTH, ZOOM_HEIGHT ].min

  # Compute the scaled dimensions of the game screen
  ZOOMED_WIDTH = GAME_WIDTH * ZOOM
  ZOOMED_HEIGHT = GAME_HEIGHT * ZOOM

  # adjustments for the game resolution
  # scale in both x and y directions is the same
  SF = 16 / ZOOM # scale factor
  WS = 48 / ZOOM # wall size
  WR = GAME_WIDTH / 320

  attr_gtk

  def game_init
    @room_rows = 45 # 720 / 16
    @room_cols = 80 # 1280 / 16
    @segment_height = SF * 12 + 2 * SF
    @segment_width = SF * 14 + 2 * SF
    @inner_wall_rect = {
      node_1: {
        W: { x: 16  * WR, y: 112 * WR, w: 60 * WR, h: 12 * WR },
        N: { x: 64  * WR, y: 112 * WR, w: 12 * WR, h: 52 * WR },
        E: { x: 64  * WR, y: 112 * WR, w: 60 * WR, h: 12 * WR }, 
        S: { x: 64  * WR, y: 72  * WR, w: 12 * WR, h: 52 * WR }
      },
      node_2: {
        W: { x: 76  * WR, y: 112 * WR, w: 60 * WR, h: 12 * WR },
        N: { x: 124 * WR, y: 112 * WR, w: 12 * WR, h: 52 * WR },
        E: { x: 124 * WR, y: 112 * WR, w: 60 * WR, h: 12 * WR },
        S: { x: 124 * WR, y: 72  * WR, w: 12 * WR, h: 52 * WR }
      },
      node_3: {
        W: { x: 136 * WR, y: 112 * WR, w: 60 * WR, h: 12 * WR },
        N: { x: 184 * WR, y: 112 * WR, w: 12 * WR, h: 52 * WR },
        E: { x: 184 * WR, y: 112 * WR, w: 60 * WR, h: 12 * WR },
        S: { x: 184 * WR, y: 72  * WR, w: 12 * WR, h: 52 * WR }
      },
      node_4: {
        W: { x: 196 * WR, y: 112 * WR, w: 60 * WR, h: 12 * WR },
        N: { x: 244 * WR, y: 112 * WR, w: 12 * WR, h: 52 * WR },
        E: { x: 244 * WR, y: 112 * WR, w: 60 * WR, h: 12 * WR },
        S: { x: 244 * WR, y: 72  * WR, w: 12 * WR, h: 52 * WR }
      },
      node_5: {
        W: { x: 16  * WR, y: 60  * WR, w: 60 * WR, h: 12 * WR }, 
        N: { x: 64  * WR, y: 60  * WR, w: 12 * WR, h: 52 * WR }, 
        E: { x: 64  * WR, y: 60  * WR, w: 60 * WR, h: 12 * WR },
        S: { x: 64  * WR, y: 20  * WR, w: 12 * WR, h: 52 * WR }
      },
      node_6: {
        W: { x: 76  * WR, y: 60  * WR, w: 60 * WR, h: 12 * WR },
        N: { x: 124 * WR, y: 60  * WR, w: 12 * WR, h: 52 * WR },
        E: { x: 124 * WR, y: 60  * WR, w: 60 * WR, h: 12 * WR },
        S: { x: 124 * WR, y: 20  * WR, w: 12 * WR, h: 52 * WR }
      },
      node_7: {
        W: { x: 136 * WR, y: 60  * WR, w: 60 * WR, h: 12 * WR },
        N: { x: 184 * WR, y: 60  * WR, w: 12 * WR, h: 52 * WR },
        E: { x: 184 * WR, y: 60  * WR, w: 60 * WR, h: 12 * WR },
        S: { x: 184 * WR, y: 20  * WR, w: 12 * WR, h: 52 * WR }
      },
      node_8: {
        W: { x: 196 * WR, y: 60  * WR, w: 60 * WR, h: 12 * WR },
        N: { x: 244 * WR, y: 60  * WR, w: 12 * WR, h: 52 * WR },
        E: { x: 244 * WR, y: 60  * WR, w: 60 * WR, h: 12 * WR },
        S: { x: 244 * WR, y: 20  * WR, w: 12 * WR, h: 52 * WR }
      }
    }
    @waypoint_positions = [
      { x: 40  * WR, y: 144 * WR, w: 1  * WR, h: 1  * WR }, # section 1
      { x: 40  * WR, y: 92  * WR, w: 1  * WR, h: 1  * WR }, # section 2
      { x: 40  * WR, y: 40  * WR, w: 1  * WR, h: 1  * WR }, # section 3

         
      { x: 100 * WR, y: 144 * WR, w: 1  * WR, h: 1  * WR }, # section 4
      { x: 100 * WR, y: 92  * WR, w: 1  * WR, h: 1  * WR }, # section 5
      { x: 100 * WR, y: 40  * WR, w: 1  * WR, h: 1  * WR }, # section 6
      
      { x: 160 * WR, y: 144 * WR, w: 1  * WR, h: 1  * WR }, # section 7    
      { x: 160 * WR, y: 92  * WR, w: 1  * WR, h: 1  * WR }, # section 8    
      { x: 160 * WR, y: 40  * WR, w: 1  * WR, h: 1  * WR }, # section 9        
            
      { x: 220 * WR, y: 144 * WR, w: 1  * WR, h: 1  * WR }, # section 10
      { x: 220 * WR, y: 92  * WR, w: 1  * WR, h: 1  * WR }, # section 11   
      { x: 220 * WR, y: 40  * WR, w: 1  * WR, h: 1  * WR }, # section 12   
                  
      { x: 280 * WR, y: 144 * WR, w: 1  * WR, h: 1  * WR }, # section 13      
      { x: 280 * WR, y: 92  * WR, w: 1  * WR, h: 1  * WR }, # section 14       
      { x: 280 * WR, y: 40  * WR, w: 1  * WR, h: 1  * WR }  # section 15      
    ]
    @waypoint_rects = []
    @waypoint_rects << Array.map( @waypoint_positions ) do |w|
      w.merge( w: 12 * WR, h: 12 * WR, w: 12  * WR, h: 12  * WR, path: :solid, anchor_x: 0.5, anchor_y: 0.5, r: 200, g: 200, b: 200 ).border!
    end

    @wall_dir = nil
    @debug_waypoint = nil
    @maze_primitives = []         # primitives to shovel to maze render target
    @wall_rects = []              # hold collision rects for all the walls
  end

  def regenerate_layout
    # this method rebuilds the maze layout data based on the room number
    return if @room_number == -1
    
    @room_grid ||= Array.new( @room_rows ) { Array.new( @room_cols, 0 ) }
    update_room_info      # used to decide which sprites to use, like at a junction
    update_wall_sprites   # update primitives with sprite info for maze based on the room   
  end
  
  def regenerate_maze
    # this method rebuilds a fresh maze render target when required
    outputs[ :room ].w = GAME_WIDTH
    outputs[ :room ].h = GAME_HEIGHT
    outputs[ :room ].background_color = [ 0, 0, 0 ]
    
    add_diag_to_room
    
    # perhaps additional render targets, avoid rebuilding this every frame
    outputs[ :room ].primitives << @maze_primitives
  
    # clear this for the next tick - need different things here, maze one should be only for drawing the maze
    @regenerate_maze_rt = nil
    @maze_primitives.clear
    @room_grid = nil
    @wall_dir = nil
  end
  
  def update_wall_sprites
    draw_wall_segment_sprites( x: 3,  y: 4,  dir: :N )
    draw_wall_segment_sprites( x: 3,  y: 30, dir: :N )
    draw_wall_segment_sprites( x: 78, y: 4,  dir: :N )
    draw_wall_segment_sprites( x: 78, y: 30, dir: :N )
    draw_wall_segment_sprites( x: 3,  y: 4,  dir: :E )
    draw_wall_segment_sprites( x: 3,  y: 43, dir: :E )
    draw_wall_segment_sprites( x: 18, y: 4,  dir: :E )
    draw_wall_segment_sprites( x: 18, y: 43, dir: :E )
    draw_wall_segment_sprites( x: 48, y: 4,  dir: :E )
    draw_wall_segment_sprites( x: 48, y: 43, dir: :E )
    draw_wall_segment_sprites( x: 63, y: 4,  dir: :E )
    draw_wall_segment_sprites( x: 63, y: 43, dir: :E )
        
    @maze_primitives << { x:  1 * SF, y:  2 * SF,      w: WS, h: WS, path: "sprites/walls/wall_5.png"  }
    @maze_primitives << { x:  1 * SF, y: 42 * SF - SF, w: WS, h: WS, path: "sprites/walls/wall_12.png" }
    @maze_primitives << { x: 76 * SF, y: 42 * SF - SF, w: WS, h: WS, path: "sprites/walls/wall_10.png" }
    @maze_primitives << { x: 76 * SF, y:  2 * SF,      w: WS, h: WS, path: "sprites/walls/wall_3.png"  }

    @maze_primitives << { x: 31 * SF, y:  2 * SF,      w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x: 32, y: 3  ) }.png" }
    @maze_primitives << { x: 31 * SF, y: 41 * SF,      w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x: 32, y: 42 ) }.png" }
    @maze_primitives << { x: 46 * SF, y:  2 * SF,      w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x: 47, y: 3  ) }.png" }
    @maze_primitives << { x: 46 * SF, y: 41 * SF,      w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x: 47, y: 42 ) }.png" }

    @maze_primitives << { x: 16 * SF, y:  2 * SF,      w: WS, h: WS, path: "sprites/walls/wall_6.png" }
    @maze_primitives << { x: 16 * SF, y: 41 * SF,      w: WS, h: WS, path: "sprites/walls/wall_6.png" }
    @maze_primitives << { x: 61 * SF, y:  2 * SF,      w: WS, h: WS, path: "sprites/walls/wall_6.png" }
    @maze_primitives << { x: 61 * SF, y: 41 * SF,      w: WS, h: WS, path: "sprites/walls/wall_6.png" }

    @maze_primitives << { x:  1 * SF, y: 15 * SF,      w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x: 2,  y: 16 ) }.png" }
    @maze_primitives << { x:  1 * SF, y: 28 * SF,      w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x: 2,  y: 29 ) }.png" }
    @maze_primitives << { x: 76 * SF, y: 15 * SF,      w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x: 77, y: 16 ) }.png" }
    @maze_primitives << { x: 76 * SF, y: 28 * SF,      w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x: 77, y: 29 ) }.png" }
    
    @wall_seed = @room_number
    draw_wall_segment_sprites( x: 18, y: 30, dir: get_direction )
    draw_wall_segment_sprites( x: 33, y: 30, dir: get_direction )
    draw_wall_segment_sprites( x: 48, y: 30, dir: get_direction )
    draw_wall_segment_sprites( x: 63, y: 30, dir: get_direction )
    draw_wall_segment_sprites( x: 18, y: 17, dir: get_direction )
    draw_wall_segment_sprites( x: 33, y: 17, dir: get_direction )
    draw_wall_segment_sprites( x: 48, y: 17, dir: get_direction )
    draw_wall_segment_sprites( x: 63, y: 17, dir: get_direction )
    
    @maze_primitives << { x: 31 * SF, y: 41 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x: 32, y: 42 ) }.png" }
    @maze_primitives << { x: 46 * SF, y: 41 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x: 47, y: 42 ) }.png" }
    @maze_primitives << { x:  1 * SF, y: 15 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x:  2, y: 16 ) }.png" }
    @maze_primitives << { x:  1 * SF, y: 28 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x:  2, y: 29 ) }.png" }

    @maze_primitives << { x: 16 * SF, y:  2 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x: 17, y:  3 ) }.png" }
    @maze_primitives << { x: 16 * SF, y: 41 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x: 17, y: 42 ) }.png" }
    @maze_primitives << { x: 61 * SF, y:  2 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x: 62, y:  3 ) }.png" }
    @maze_primitives << { x: 61 * SF, y: 41 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x: 62, y: 42 ) }.png" }

    @maze_primitives << { x: 31 * SF, y: 15 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x: 32, y: 16 ) }.png" }
    @maze_primitives << { x: 46 * SF, y: 15 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x: 47, y: 16 ) }.png" }
    @maze_primitives << { x: 61 * SF, y: 15 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x: 62, y: 16 ) }.png" }
    @maze_primitives << { x: 16 * SF, y: 15 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x: 17, y: 16 ) }.png" }
    @maze_primitives << { x: 31 * SF, y: 28 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x: 32, y: 29 ) }.png" }
    @maze_primitives << { x: 46 * SF, y: 28 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x: 47, y: 29 ) }.png" }
    @maze_primitives << { x: 61 * SF, y: 28 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x: 62, y: 29 ) }.png" }
    @maze_primitives << { x: 16 * SF, y: 28 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x: 17, y: 29 ) }.png" }

    @maze_primitives << { x: 76 * SF, y: 15 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x: 77, y: 16 ) }.png" }
    @maze_primitives << { x: 76 * SF, y: 28 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x: 77, y: 29 ) }.png" }
    @maze_primitives << { x: 31 * SF, y:  2 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x: 32, y:  3 ) }.png" }
    @maze_primitives << { x: 46 * SF, y:  2 * SF, w: WS, h: WS, path: "sprites/walls/wall_#{ choose_junction_sprite( x: 47, y:  3 ) }.png" }

  end
  
  def draw_wall_segment_sprites( x:, y:, dir: )
    case dir
    when :N
      4.times do |i|
        @maze_primitives <<  { x: ( x - 2 ) * SF,
                               y: y * SF + ( i * WS ),
                               w: WS,
                               h: WS,
                               path: "sprites/walls/wall_9.png" }
      end
    when :S
      4.times do |i|
        @maze_primitives <<  { x: ( x - 2 ) * SF,
                               y: y * SF + ( i * WS ) - @segment_height + SF,
                               w: WS,
                               h: WS,
                               path: "sprites/walls/wall_9.png" }
      end
    when :E
      4.times do |i|
        @maze_primitives <<  { x: ( x + 1 ) * SF + ( i * WS ),
                               y: ( y - 2 ) * SF,
                               w: WS,
                               h: WS,
                               path: "sprites/walls/wall_6.png" }
      end
    when :W
      4.times do |i|
        @maze_primitives <<  { x: ( x + 1 ) * SF + ( i * WS ) - @segment_width + SF,
                               y: ( y - 2 ) * SF,
                               w: WS,
                               h: WS,
                               path: "sprites/walls/wall_6.png" }
      end
    end
  end
  
  # we want to check the game grid coordinates at x: 3, y: 4,
  # this is at x: 2, y: 3 in 2d array, since 0, 0 is bottom left corner
  def choose_junction_sprite( x:, y: )
    n = ( @room_grid[ y + 1 ][ x ] == 1 ) ? 1 : 0
    s = ( @room_grid[ y - 1 ][ x ] == 1 ) ? 1 : 0
    e = ( @room_grid[ y ][ x + 1 ] == 1 ) ? 1 : 0
    w = ( @room_grid[ y ][ x - 1 ] == 1 ) ? 1 : 0
    # return autotile bits in decimal form
    "#{ s }#{ e }#{ w }#{ n }".to_i( 2 )
  end
  
  def update_room_info
    update_room_grid( x: 3,  y: 4,  dir: :N )
    update_room_grid( x: 3,  y: 30, dir: :N )
    update_room_grid( x: 78, y: 4,  dir: :N )
    update_room_grid( x: 78, y: 30, dir: :N )
    update_room_grid( x: 3,  y: 4,  dir: :E )
    update_room_grid( x: 3,  y: 43, dir: :E )
    update_room_grid( x: 18, y: 4,  dir: :E )
    update_room_grid( x: 18, y: 43, dir: :E )
    update_room_grid( x: 48, y: 4,  dir: :E )
    update_room_grid( x: 48, y: 43, dir: :E )
    update_room_grid( x: 63, y: 4,  dir: :E )
    update_room_grid( x: 63, y: 43, dir: :E )
    @wall_seed = @room_number
    
    # outer walls that don't change
    @wall_rects = [
      { x: 16  * WR, y: 8   * WR, w: 120 * WR, h: 12 * WR },
      { x: 16  * WR, y: 164 * WR, w: 120 * WR, h: 12 * WR },
      { x: 184 * WR, y: 8   * WR, w: 120 * WR, h: 12 * WR },
      { x: 184 * WR, y: 164 * WR, w: 120 * WR, h: 12 * WR },
      
      { x: 4   * WR, y: 20  * WR, w: 12  * WR, h: 52 * WR },
      { x: 304 * WR, y: 20  * WR, w: 12  * WR, h: 52 * WR },
      { x: 4   * WR, y: 112 * WR, w: 12  * WR, h: 52 * WR },
      { x: 304 * WR, y: 112 * WR, w: 12  * WR, h: 52 * WR }
    ]
  
    # inner walls, different layout depending on the room number
    update_room_grid( x: 18, y: 30, dir: get_direction )
    @wall_rects << @inner_wall_rect[ :node_1 ][ @wall_dir ]
    
    update_room_grid( x: 33, y: 30, dir: get_direction )
    @wall_rects << @inner_wall_rect[ :node_2 ][ @wall_dir ]
    
    update_room_grid( x: 48, y: 30, dir: get_direction )
    @wall_rects << @inner_wall_rect[ :node_3 ][ @wall_dir ]
    
    update_room_grid( x: 63, y: 30, dir: get_direction )
    @wall_rects << @inner_wall_rect[ :node_4 ][ @wall_dir ]
    
    update_room_grid( x: 18, y: 17, dir: get_direction )
    @wall_rects << @inner_wall_rect[ :node_5 ][ @wall_dir ]
    
    update_room_grid( x: 33, y: 17, dir: get_direction )
    @wall_rects << @inner_wall_rect[ :node_6 ][ @wall_dir ]
    
    update_room_grid( x: 48, y: 17, dir: get_direction )
    @wall_rects << @inner_wall_rect[ :node_7 ][ @wall_dir ]
    
    update_room_grid( x: 63, y: 17, dir: get_direction )
    @wall_rects << @inner_wall_rect[ :node_8 ][ @wall_dir ]
  end
  
  # this is a version of the generation system used in the arcade game berzerk
  # it follows the same patterns as the arcade game following a reset.
  def get_direction
    n1 = 0x7
    n2 = 0x3153
    r1 = ( @wall_seed * n1 ) & 0xFFFF
    r2 = ( r1 + n2 ) & 0xFFFF
    r3 = ( r2 * n1 ) & 0xFFFF
    result = ( r3 + n2 ) & 0xFFFF
    @wall_seed = result
    high_8_bits = ( result >> 8 ) & 0xFF
    low_2_bits = high_8_bits & 0x03

    case low_2_bits
    when 0
      @wall_dir = :N
      :N
    when 1
      @wall_dir = :S
      :S
    when 2
      @wall_dir = :E
      :E
    when 3
      @wall_dir = :W
      :W
    end
  end
  
  def update_room_grid( x:, y:, dir: )
    case dir
    when :N
      14.times do |i|
        @room_grid[ y - 1 + i ][ x - 1 ] = 1
      end
    when :S
      14.times do |i|
        @room_grid[ y + i - 14 ][ x - 1 ] = 1
      end
    when :E
      16.times do |i|
        @room_grid[ y - 1][ x + i - 1] = 1
      end
    when :W
      16.times do |i|
        @room_grid[ y - 1][ x + i - 16] = 1
      end
    end
  end
  
  def add_diag_to_room
    return unless @show_diag
    
    # debug show wall rects
    @maze_primitives << Array.map( @wall_rects ) do |w|
      w.merge( path: :solid, r: 200, g: 200, b: 200 ).border!
    end
    # debug show waypoint_rects
    @maze_primitives.concat(@waypoint_rects)
    @maze_primitives << @start_position.merge( w: 12 * WR, h: 12 * WR, w: 12  * WR, h: 12  * WR, path: :solid, anchor_x: 0.5, anchor_y: 0.5, r: 0, g: 200, b: 0 ).border!
    @maze_primitives << @end_position.merge( w: 12 * WR, h: 12 * WR, w: 12  * WR, h: 12  * WR, path: :solid, anchor_x: 0.5, anchor_y: 0.5, r: 0, g: 0, b: 250 ).border!
    
    if @debug_waypoint
      @maze_primitives << @debug_waypoint.merge( w: 12 * WR, h: 12 * WR, path: :solid, anchor_x: 0.5, anchor_y: 0.5, r: 255, g: rand( 255 ), b: rand( 255 ) ).solid!
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
