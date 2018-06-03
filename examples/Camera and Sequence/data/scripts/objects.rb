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
    init(:gem) #gem is added also to :gem entity group, which is array of index 1 in $state.entities ; define your groups in specjal.rb line 166+
  end
  
  def update
    if (@x - $state.player.x).abs < 50 and (@y - $state.player.y).abs < 50
      Snd['Beep'].play
      remove
    end
  end
  
  def draw
    # Draw, slowly rotating
    Img['CptnSapphire Gem'].draw_rot(@x, @y, 1, 25 * Math.sin(milliseconds / 133.7))
  end
end

class TNT < Entity
  def initialize(x,y)
    @x,@y=x,y
    init
  end
  
  def draw
    Img['TNT'].draw_rot(@x,@y,1, 25 * Math.sin(milliseconds / 133.7))
  end
end

class Console < Entity
  def initialize(x,y)
    @x,@y=x,y
    init
    
    @security=Camera.new(1280,1280) #the 'security camera' is used to see distant places
    @security.shader(Ashton::Shader.new(fragment: :sepia)) #set shader to the camera
  end
  
  def update
    @security.boundary(0,0,$state.map.width,$state.map.height) #make sure camera won't show out of map
    if (@x - $state.player.x).abs < 120 and (@y - $state.player.y).abs < 120 #check if player is near
      @can_interact=true
    else
      @can_interact=nil
    end
    
    if @can_interact and !@see and Keypress[KbDown,false] #can interact and key is pressed
      $state.set_camera(@security) #change camera if interacting
      @see=true
      #to make it more fun, you can still walk while looking through secam
    elsif @see and Keypress[KbDown,false] #stop looking when key is pressed again
      $state.default_camera #restore game's camera to previously selected one
      @see=nil
    end
  end
  
  def draw
    Img['Computer'].draw_rot(@x,@y,0, 25 * Math.sin(milliseconds / 133.7))
    Fnt[FONT,20].draw("Press Down to interact",$state.camera.pos_x+20,$state.camera.pos_y+60,5) if @can_interact and !@see #draw text if player near
    Fnt[FONT,20].draw("Press Down to de-interact",$state.camera.pos_x+20,$state.camera.pos_y+60,5) if @can_interact and @see #draw text if seeing
  end
end