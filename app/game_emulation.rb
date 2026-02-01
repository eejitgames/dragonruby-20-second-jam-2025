WIDTH = 1280
HEIGHT = 720

GAME_WIDTH  = 320
GAME_HEIGHT = 180

ZOOM_WIDTH =  ( WIDTH / GAME_WIDTH ).floor
ZOOM_HEIGHT = ( HEIGHT / GAME_HEIGHT ).floor
ZOOM = [ ZOOM_WIDTH, ZOOM_HEIGHT ].min

ZOOMED_WIDTH = GAME_WIDTH * ZOOM
ZOOMED_HEIGHT = GAME_HEIGHT * ZOOM

def self.boot args
  args.state = {}
end

def self.tick args
  args.outputs.background_color = [ 0, 0, 0 ]
  args.outputs[ :room ].set w: GAME_WIDTH,
                            h: GAME_HEIGHT,
                            background_color: [ 73, 81, 105, 255 ]

  $game ||= Game.new
  $game.args = args
  $game.tick

  args.outputs.sprites << {
      x: $game.camera.x * ZOOM,
      y: $game.camera.y * ZOOM,
      w: ZOOMED_WIDTH,
      h: ZOOMED_HEIGHT,
      path: :room
      }
end

def self.reset args
  $game = nil
end
