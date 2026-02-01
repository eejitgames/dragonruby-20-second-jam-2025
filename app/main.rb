require_relative "game_emulation"
require_relative "camera"

class Game
  attr_gtk
  attr_reader :camera

  def initialize
    @camera = Camera.new
  end

  def tick
    @camera.add_shake 0.6 if inputs.keyboard.key_held.space
    @camera.update_shake Kernel.tick_count
    render
  end

  def render
  end
end

$gtk.disable_framerate_warning!
$gtk.reset
