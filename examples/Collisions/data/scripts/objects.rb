# Player class.
class CptnSapphire < Entity
  def initialize(x, y)
    @x, @y = x, y
    @dir = :left
    @vy = 0
    @standing, @walk1, @walk2, @jump = *Tls['CptnSapphire',50]
    @cur_image = @standing
    init
    
    @box=Collision_Box.new(@x,@y-25,50,50) #make a collision box at the center of sprite
  end
  
  def draw
    if @dir == :left then
      offs_x = -25
      factor = 1.0
    else
      offs_x = 25
      factor = -1.0
    end
    @cur_image.draw(@x + offs_x, @y - 49, 0, factor)
  end
  
  def would_fit(offs_x, offs_y)
    not $state.map.solid?(@x + offs_x, @y + offs_y) and
      not $state.solid?(@x + offs_x, @y + offs_y - 45)
  end
  
  def update
    try_to_jump if Keypress[KbUp,false]
    
    move_x = (Keypress[KbLeft] ? -5 : Keypress[KbRight] ? 5 : 0)
    
    if (move_x == 0)
      @cur_image = @standing
    else
      @cur_image = (milliseconds / 175 % 2 == 0) ? @walk1 : @walk2
    end
    if (@vy < 0)
      @cur_image = @jump
    end
    
    
    if move_x > 0 then
      @dir = :right
      move_x.times { if would_fit(1, 0) then @x += 1 end }
    end
    if move_x < 0 then
      @dir = :left
      (-move_x).times { if would_fit(-1, 0) then @x -= 1 end }
    end

    @vy += 1
    if @vy > 0 then
      @vy.times { if would_fit(0, 1) then @y += 1 else @vy = 0 end }
    end
    if @vy < 0 then
      (-@vy).times { if would_fit(0, -1) then @y -= 1 else @vy = 0 end }
    end
    
    @box.set(@x,@y-25) #update Box position
    
    if $state.find(1) {|ent| @box.collides?(ent.col)} #check if collides with any trap
      #teleport if yes
      @x=128
      @y=1280
    end
  end
  
  def try_to_jump
    if $state.map.solid?(@x, @y + 1) then
      @vy = -20
    end
  end
end

class Rotor < Entity
  attr_reader :col
  def initialize(x,y)
    @x,@y=x,y
    
    @col=Collision_Box.new(@x,@y,40,200) #add a box for collisions ; it's positioned in the center
    @angle=0
    
    init(:trap) #push to traps' group
  end
  
  def update
    @angle-=1 #change angle
    @col.set(@x,@y,@angle) #update box position/angle
  end
  
  def draw
    Img['Rotor'].draw_rot(@x,@y,2,@angle) #sprite is drawn in the center to make it easier
  end
end

class Ball < Entity
  attr_reader :col
  def initialize(x,y)
    @x,@y=x,y
    
    @col=Collision_Ball.new(@x,@y,120)
    
    init(:trap)
  end
  
  def draw
    Img['Ball'].draw_rot(@x,@y,2,0)
  end
end

class Cage < Entity
  attr_reader :col
  def initialize(x,y)
    @x,@y=x,y
    @angle=0
    
    @col=Collision_Group.new(@x,@y,0, #make a group of colliders
    Collision_Box.new(@x,@y-100,150,50), #the boxes will move relatively to initial their position and group's position
    Collision_Box.new(@x-100,@y,50,250,),
    Collision_Box.new(@x+100,@y,50,250)
    )
    
    init(:trap)
  end
  
  def update
    @angle+=1 #rotate
    @col.set(@x,@y,@angle) #update group
  end
  
  def draw
    Img['Cage'].draw_rot(@x,@y,2,@angle)
  end
end