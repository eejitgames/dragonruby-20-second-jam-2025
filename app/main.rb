require_relative "game_emulation"
require_relative "camera"
require_relative "room"

class Game
  attr_gtk
  attr_reader :camera

  def initialize
    @camera = Camera.new
    @room = Room.new
  end

  def tick
    @camera.add_shake 0.4 if inputs.keyboard.key_down.space
    @camera.update_shake Kernel.tick_count
    render
  end

  def render
  end
end

$gtk.disable_framerate_warning!
$gtk.reset
