class Camera
  attr_accessor :x, :y

  def initialize( shake_amplitude: 100, shake_freq_x: 0.5, shake_freq_y: 0.7, shake_decay: 0.95, shake_max: 0.6 )
    @shake_amplitude = shake_amplitude
    @shake_frequency_x = shake_freq_x
    @shake_frequency_y = shake_freq_y
    @shake_decay = shake_decay
    @shake_max = shake_max
    reset
  end

  def reset
    @shake = 0.0
    @x = 0
    @y = 0
  end

  def add_shake( amount )
    @shake += amount
    @shake = @shake_max if @shake > @shake_max
  end

  def update_shake( t )
    return if @shake.zero?

    s = [ @shake_amplitude * @shake**2, @shake_amplitude ].min
    @x = ( Math.sin( t * @shake_frequency_x ) * s ).floor
    @y = ( Math.cos( t * @shake_frequency_y ) * s ).floor
    @shake *= @shake_decay
    reset if @shake < 0.07
  end
end
