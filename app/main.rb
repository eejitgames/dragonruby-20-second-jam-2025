require_relative "game_emulation"

class Game
  include GameEmulation

  def initialize
    game_init
    # screen shake variables
    @camera_x_offset = 0
    @camera_y_offset = 0
    @camera_trauma = 0
    @current_scene = :title_scene # starting scene
    @room_number = -1             # blank room
    @game_mode = :planning        # planning or playing
    @show_diag = false            # frame diagnostics
    @regenerate_maze_rt = :true   # recreate maze render target
    # assign random testing positions for character start and exit position
    assign_start_and_end_positions
  end

  def tick
    scene_manager
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
  
  def game_input
    # screenshake testing
    if inputs.mouse.click
      @camera_trauma = 0.5
    end
    
    # toggle framerate diagnostics
    if inputs.keyboard.key_down.forward_slash
      @show_diag = !@show_diag
      @regenerate_maze_rt = :true
    end
    
    # temporary mode toggle via keyboard
    if inputs.keyboard.key_up.m
      if @game_mode == :planning
        @game_mode = :playing
      elsif @game_mode == :playing
        @game_mode = :planning
      end
    end
    
    # debug nearest waypoint testing
    if inputs.mouse.click
      mx = ( inputs.mouse.x ).idiv( ZOOM )
      my = ( inputs.mouse.y ).idiv( ZOOM )
      
      @debug_waypoint = find_closest_waypoint( mx, my )
      @regenerate_maze_rt = :true
    end
  end

  def find_closest_waypoint( x, y )
    @waypoint_positions.min_by do |wp|
      dx = wp.x - x
      dy = wp.y - y
      dx * dx + dy * dy
    end
  end
  
  def game_calc
    screenshake
    
    if @game_mode == :playing
      # if inputs.keyboard.key_up.n
      if Kernel.tick_count.zmod? 120
        @regenerate_maze_rt = :true
        @room_number += 1
        @room_number = 0 if @room_number > 1023
      end
      
      if @regenerate_maze_rt
        regenerate_layout
        regenerate_maze
      end
    end
  end
  
  def game_render
    outputs.background_color = [ 73, 81, 105 ]
    
    case @game_mode
    when :planning
    
    when :playing                            
      # render the game scaled to fit the screen
      outputs.primitives << {
        x: @camera_x_offset,
        y: @camera_y_offset,
        w: WIDTH,
        h: HEIGHT,
        path: :room,
      }
    end
    
    if @show_diag == true
      outputs.primitives << { x: 5,
                              y: 80,
                              text: "mod: #{ @game_mode }",
                              r: 255,
                              g: 255,
                              b: 255 }.label!
    
      outputs.primitives << { x: 5,
                              y: 61,
                              text: "fps: #{ GTK.current_framerate.round }",
                              r: 255,
                              g: 255,
                              b: 255 }.label!

      outputs.primitives << { x: 5,
                              y: 42,
                              text: "sim: #{ GTK.current_framerate_calc.round }",
                              r: 255,
                              g: 255,
                              b: 255 }.label!

      outputs.primitives << { x: 5,
                              y: 23,
                              text: "rnd: #{ GTK.current_framerate_render.round }",
                              r: 255,
                              g: 255,
                              b: 255 }.label!
    end
  end
  
  def screenshake
    return if @camera_trauma == 0
    
    next_offset = 100 * @camera_trauma**2
    t = Kernel.tick_count
    @camera_x_offset = ( Math.sin( t * 0.5 ) * next_offset )
    @camera_y_offset = ( Math.cos( t * 0.7 ) * next_offset )

    @camera_trauma *= 0.95
    if @camera_trauma < 0.05
      @camera_x_offset = 0
      @camera_y_offset = 0
      @camera_trauma = 0
      @regenerate_maze_rt = :true
      @debug_waypoint = nil
    end
  end
    
  def assign_start_and_end_positions
    # start is one of the three positions on the left
    @start_position = @waypoint_positions[0..2].sample
    # end is one of the three positions on the right
    @end_position  = @waypoint_positions[-3..-1].sample
  end  
end

GTK.disable_framerate_warning!
GTK.reset
