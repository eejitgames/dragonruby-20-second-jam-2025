class Camera
    attr_accessor :x, :y

    def initialize( shake_amplitude: 100, shake_freq_x: 0.5, shake_freq_y: 0.7, shake_decay: 0.95, shake_max: 0.6 )
        @amplitude = shake_amplitude
        @frequency_x = shake_freq_x
        @frequency_y = shake_freq_y
        @decay = shake_decay
        @shake_max = shake_max
        reset
    end

    def reset
        @x = 0
        @y = 0
        @shake = 0.0
    end

    def add_shake( amount )
        @shake += amount
        @shake = @shake_max if @shake > @shake_max
    end

    def update_shake( t )
        return if @shake.zero?

        s = [ @amplitude * @shake**2, @amplitude ].min
        @x = ( Math.sin( t * @frequency_x ) * s ).floor
        @y = ( Math.cos( t * @frequency_y ) * s ).floor
        @shake *= @decay
        reset if @shake < 0.07
    end
end
