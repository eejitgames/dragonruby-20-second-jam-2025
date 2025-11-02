require_relative "game_emulation"

class Game
  include GameEmulation

  def initialize
    game_init
    # screen shake variables
    @camera_x_offset = 0
    @camera_y_offset = 0
    @camera_trauma = 0
    @current_scene = :game_scene  # starting scene
    @room_number = -1             # blank room
    @game_mode = :planning        # planning or playing
    @show_diag = true             # frame diagnostics
    @regenerate_maze_rt = :true   # recreate maze render target
    # assign random testing positions for character start and exit position
    assign_start_and_end_positions
    @last_waypoint = @start_position
    @player = {
      x: @start_position.x,
      y: @start_position.y,
      w: 24,
      h: 24,
      path: :solid,
      anchor_x: 0.5,
      anchor_y: 0.5,
      speed: 0.2 * SF,
      mode: :walk,
      angle_facing: 270,
      frame_time: Kernel.tick_count,
      frame_dir: 1,
      frame: 0
    }
    @allowed_room_numbers = File.read( "data/room_numbers.txt" ).split( "\n" ).map( &:strip ).map( &:to_i )
    @room_selector = @allowed_room_numbers.shuffle.take( 8 ) # 8 random rooms to choose from
    @room_queue = [] # 4 room layouts to navigate during gameplay
    cols = 4
    rows = 2
    start_x = 30
    start_y = 300
    spacing_x = 320
    spacing_y = 200
    @room_options = ( rows * cols ).times.map do |i|
      row = ( i / cols ).floor
      col = ( i % cols ).floor

      {
        x: start_x + col * spacing_x,
        y: start_y + ( rows - 1 - row ) * spacing_y,
        w: 256,
        h: 144,
        path: "sprites/256x144_thumbnails/room-#{ @room_selector[i] }.png",
        id: i + 1,
        room_number: @room_selector[i]
      }
    end
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
      # @camera_trauma = 0.5
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

    planning_check_thumbnail_selected
    playing_check_waypoint_selected
  end

  def game_calc
    screenshake

    if @game_mode == :playing
      # if inputs.keyboard.key_up.n
      #if Kernel.tick_count.zmod? 120
      #  @regenerate_maze_rt = :true
      #  # @room_number += 1
      #  @room_number = 0 if @room_number > 1023
      #end

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
      outputs.primitives << @room_options
      outputs.primitives << @room_queue

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

  def add_room_to_queue(id)
    return if @room_queue.any? { |r| r[:id] == id }

    room_data = @room_options.find { |r| r[:id] == id }
    return unless room_data

    occupied_indices = @room_queue.map { |r| r[:queue_index] }
    slot_index = (0..3).find { |i| !occupied_indices.include?(i) }
    return unless slot_index  # queue full

    x_start = 30
    y_start = 100
    spacing_x = 320
    spacing_y = 0
    x = x_start + slot_index * spacing_x
    y = y_start + spacing_y

    @room_queue << {
      id: room_data[:id],
      path: room_data[:path],
      w: room_data[:w],
      h: room_data[:h],
      queue_index: slot_index,
      x: x,
      y: y
    }
  end

  def planning_check_thumbnail_selected
    return if @game_mode != :planning

    if inputs.mouse.click
      clicked_queue_room = @room_queue.find do |r|
        inputs.mouse.intersect_rect? r
      end

      if clicked_queue_room
        putz "room removed from the queue: #{clicked_queue_room[:id]}"
        putz "position removed from queue: #{clicked_queue_room[:queue_index]}"
        @room_queue.delete(clicked_queue_room)

        putz "is the queue empty ? #{@room_queue.empty?}"

        return
      end

      button = @room_options.find do |r|
        inputs.mouse.intersect_rect? r
      end

      if button
        putz "clicked button: #{ button.id }"
        putz "room number: #{ button.room_number }"
        add_room_to_queue(button[:id])
      end
    end
  end

  def playing_check_waypoint_selected
    return if @game_mode != :playing

    # debug nearest waypoint testing
    if inputs.mouse.click

      putz "is the queue empty ? #{@room_queue.empty?}"

      mx = ( inputs.mouse.x ).idiv( ZOOM )
      my = ( inputs.mouse.y ).idiv( ZOOM )

      test_wp = find_closest_waypoint( mx, my )
      get_waypoint_distance @last_waypoint, test_wp

      if @waypoint_distance <= 3600
        @debug_waypoint = test_wp
        @regenerate_maze_rt = :true
        # set this here for now, independant from player movement
        @last_waypoint = @debug_waypoint
        @camera_trauma = 0.2
      else
        debug_waypoint = nil
      end
    # if you are planning, or the room queue is empty then you cannot place items
    end unless @game_mode == :planning || @room_queue.empty?
  end

  def find_closest_waypoint( x, y )
    @waypoint_positions.min_by do |wp|
      dx = wp.x - x
      dy = wp.y - y
      dx * dx + dy * dy
    end
  end

  def get_waypoint_distance( p1, p2)
    dx = p1.x - p2.x
    dy = p1.y - p2.y
    @waypoint_distance = dx * dx + dy * dy
    @waypoint_distance
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
    @start_position = @waypoint_positions[ 0..2 ].sample
    # end is one of the three positions on the right
    @end_position  = @waypoint_positions[ -3..-1 ].sample
  end
end

GTK.disable_framerate_warning!
GTK.reset
