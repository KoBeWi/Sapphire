# Player class.
class CptnSapphire < Entity
  def initialize(x, y)
    @x, @y = x, y
    @dir = :left
    @vy = 0 # Vertical velocity
    # Load all animation frames using a Tls class
    @standing, @walk1, @walk2, @jump = *Tls['CptnSapphire',50]
    # This always points to the frame that is currently drawn.
    # This is set in update, and used in draw.
    @cur_image = @standing
    init #this important thing makes entity automatically draw and update
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
    not $state.map.solid?(@x + offs_x, @y + offs_y) and #acces map with $state global variable and :map reader
      not $state.solid?(@x + offs_x, @y + offs_y - 45)
  end
  
  def update
    try_to_jump if Keypress[KbUp,false] #jump if Up key is single pressed
    
    move_x = (Keypress[KbLeft] ? -5 : Keypress[KbRight] ? 5 : 0) #move_x changes if Left or Right are pressed
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
      (-@vy).times { if would_fit(0, -1) then @y -= 1 else @vy = 0 end }
    end
  end
  
  def try_to_jump
    if $state.map.solid?(@x, @y + 1) then
      @vy = -20
    end
  end
end

class CollectibleGem < Entity
  def initialize(x, y)
    @x, @y = x, y
    init
  end
  
  def update
    if (@x - $state.player.x).abs < 50 and (@y - $state.player.y).abs < 50 #deteck if player collides with gem
      Snd['Beep'].play #play a beep
      remove #wipe out the gem from existence (so it won't update/draw anymore)
    end
  end
  
  def draw
    # Draw, slowly rotating
    Img['CptnSapphire Gem'].draw_rot(@x, @y, 1, 25 * Math.sin(milliseconds / 133.7)) #notice the Img method, that loads image from data/gfx directory
  end
end