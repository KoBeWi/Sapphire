class Game
  attr_accessor :lighting_enabled
  attr_reader :entities,:camera,:lights
  
  FLASH_Z=5 #Z order of flash effect
  SHAKE_Z=5 #Z order of shake effect's boundary
  DARK_Z=5 #Z order of shadows
  GROUPS=1 #number of entity groups (define in specjal.rb 167+)
  
  def initialize
		$state=self
		reset
    @removed=[]
    @lights=[]
    @camera=Camera.new($screen.width/2,$screen.height/2) #default camera ; variable can't be empty
    @dark=Ashton::WindowBuffer.new
  end
  
  def update
		@entities[0].each {|ent| ent.update if ent.respond_to?(:update) and !ent.stop and !ent.removed}
    
    @removed.each{|ent| @entities.each{|grp| grp.delete(ent)}}
    @removed.clear
    
    x=$screen.mouse_x ; y=$screen.mouse_y #so writing is shorter
    Trace.new(x-8,y-8,1,'Growth',8) if $time%4==0 #leave simple trace for cursor
    
    if Keypress[Kb1] and $time%4==0
      vx=-8+rand(17) #randomize speed
      Particle.new(x-8,y-8,1,['Ice Shard',16,16,rand(3)], vx , -rand(9),:rotate=>vx*8) #shoot particle
    end
    
    Trail.new(x,y,2,['Splash',60,29],4) if Keypress[Kb2,false] #simple splash effect
    Trail.new(x,y,2,['Dust',32,32],4) if Keypress[Kb3] #some dust
    Trail.new(x,y,2,['Teleport Vanish',50,96],4,:sequence=>([0,1]*4 + [2,3]*4 + [3,4]*4 + [5,6,7,8,9])) if Keypress[Kb4,false] #complex sequenced animation
    
    shake(8,5,8) if Keypress[Kb5,false] #small shake
    shake(24,1,32) if Keypress[Kb6,false] #violent shake
    
    flash(Color::WHITE,16) if Keypress[Kb7,false] #instant flash
    flash(Color::GREEN,2,true) if Keypress[Kb8,false] #slow flash
  end
  
  def draw
    if @lighting_enabled
      @dark.render{ Img['core/Dark'].draw(0,0,0)
      @lights.each{|light| Tls['core/Light',256][light.luminance-1].draw_rot(light.x - @camera.pos_x,light.y - @camera.pos_y,0,0,0.5,0.5,light.radius/256.0,light.radius/256.0,light.color,:additive)}}
    end
    @lights.clear
    
    $screen.translate(-@camera.pos_x,-@camera.pos_y) do
      Img['Space'].draw(0,0,0) #draw background considering camera
      
      if @camera.shader?
        $screen.post_process @camera.shader? do
          @entities[0].each {|ent| ent.draw if ent.respond_to?(:draw) and !ent.invisible and !ent.removed}
        end
      else
        @entities[0].each {|ent| ent.draw if ent.respond_to?(:draw) and !ent.invisible and !ent.removed}
      end
    end
    
    if @flash
      alpha=(@flash[0].alpha+(@flash[2] ? @flash[1] : -@flash[1]))
      if @flash[2] and alpha>255
        @flash[2]=nil
        @flash[0].alpha=255
      elsif !@flash[2] and alpha<0
        @flash=nil
      end
      
      if @flash
        @flash[0].alpha=alpha
        $screen.draw_quad(0,0,@flash[0],$screen.width,0,@flash[0],$screen.width,$screen.height,@flash[0],0,$screen.height,@flash[0],FLASH_Z)
      end
    end
    
    if @lighting_enabled
      @dark.draw(0,0,DARK_Z,:mode=>:multiply)
    end
  end

	def solid?(x,y,down=true)
	end
  
  def flash(color,speed,starting=nil)
    clr=(color.class==Color ? color.dup : Color.new(color))
    clr.alpha=0 if starting and clr.alpha==255
    @flash=[clr,speed,starting]
  end
  
	def shake(max,time,num)
		@camera.shake(max,time,num)
	end

	def reset
		@entities=[[]] ; GROUPS.times{@entities<<[]}
	end

	def missing?(obj)
		!@entities[0].include?(obj) or obj.removed
	end
  
  def find(group=0)
    @entities[group].find{|ent| yield(ent)}
  end
  
  def remove(ent)
    @removed << ent
  end
  
  def set_camera(camera)
    @camera=camera
  end
  
  def set_default_camera(camera)
    @default_camera=camera
  end
  
  def default_camera
    @camera=@default_camera
  end
  
  def shake_z
    SHAKE_Z
  end
  
  def play(sample,x,y,volume=$screen.width*2,speed=1)
    scx=@camera.pos_x+$screen.width/2
    scy=@camera.pos_y+$screen.height/2
    unit=volume.to_i/10
    pan=10*((x-scx).abs.to_i/unit)*0.01*(x<=>scx)
    Snd[sample].play_pan(pan,[(volume-distance(scx,scy,x,y))*2/volume,0].max)
  end
end