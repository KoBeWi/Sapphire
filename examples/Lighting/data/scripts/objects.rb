# Player class.
class CptnSapphire < Entity
  def initialize(x, y)
    @x, @y = x, y
    @dir = :left
    @vy = 0 # Vertical velocity
    # Load all animation frames
    @standing, @walk1, @walk2, @jump = *Tls['CptnSapphire',50]
    # This always points to the frame that is currently drawn.
    # This is set in update, and used in draw.
    @cur_image = @standing
    init
    
    @light=Light.new(@x,@y,250)
  end
  
  def draw
    # Flip vertically when facing to the left.
    if @dir == :left then
      offs_x = -25
      factor = 1.0
    else
      offs_x = 25
      factor = -1.0
    end
    @cur_image.draw(@x + offs_x, @y - 49, 0, factor)
  end
  
  # Could the object be placed at x + offs_x/y + offs_y without being stuck?
  def would_fit(offs_x, offs_y)
    # Check at the center/top and center/bottom for map collisions
    not $state.map.solid?(@x + offs_x, @y + offs_y) and
      not $state.solid?(@x + offs_x, @y + offs_y - 45)
  end
  
  def update
    @light.x=@x
    @light.y=@y
    
    try_to_jump if Keypress[KbUp,false]
    
    move_x = (Keypress[KbLeft] ? -5 : Keypress[KbRight] ? 5 : 0)
    # Select image depending on action
    if (move_x == 0)
      @cur_image = @standing
    else
      @cur_image = (milliseconds / 175 % 2 == 0) ? @walk1 : @walk2
    end
    if (@vy < 0)
      @cur_image = @jump
    end
    
    # Directional walking, horizontal movement
    if move_x > 0 then
      @dir = :right
      move_x.times { if would_fit(1, 0) then @x += 1 end }
    end
    if move_x < 0 then
      @dir = :left
      (-move_x).times { if would_fit(-1, 0) then @x -= 1 end }
    end

    # Acceleration/gravity
    # By adding 1 each frame, and (ideally) adding vy to y, the player's
    # jumping curve will be the parabole we want it to be.
    @vy += 1
    # Vertical movement
    if @vy > 0 then
      @vy.times { if would_fit(0, 1) then @y += 1 else @vy = 0 end }
    end
    if @vy < 0 then
      (-@vy).times { if would_fit(0, -50) then @y -= 1 end }
    end
  end
  
  def try_to_jump
    if $state.map.solid?(@x, @y + 1) then
      @vy = -23
    end
  end
  
  def collect_gems(gems)
    # Same as in the tutorial game.
    gems.reject! do |c|
      (c.x - @x).abs < 50 and (c.y - @y).abs < 50
    end
  end
end

class CollectibleGem < Entity
  def initialize(x, y)
    @x, @y = x, y
    @light=Light.new(@x,@y,128,0xff0080ff)
    init
  end
  
  def update
    if (@x - $state.player.x).abs < 50 and (@y - $state.player.y).abs < 50
      Snd['Beep'].play
      remove
      @light.remove
    end
  end
  
  def draw
    # Draw, slowly rotating
    Img['CptnSapphire Gem'].draw_rot(@x, @y, 1, 25 * Math.sin(milliseconds / 133.7))
  end
end

class Torch < Entity
  def initialize(x, y, green=false)
    @x, @y, @green = x, y, green
    @light=Light.new(@x,@y,256,green ? 0xff00ff00 : 0xffff8000)
    init
  end
  
  def update
    @light.radius=256+rand(65) if $time%4==0
    @light.color=Color.new(r=192+rand(64),[192+rand(64),r].min,0) if !@green and $time%8==0
  end
  
  def draw
    Tls['Torch',50][$time/8%3].draw_rot(@x,@y,1, 25 * Math.sin(milliseconds / 133.7))
  end
end