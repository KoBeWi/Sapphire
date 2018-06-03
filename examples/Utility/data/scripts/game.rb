class Game
  attr_reader :entities,:camera,:map,:player
  
  FLASH_Z=5 #Z order of flash effect
  SHAKE_Z=5 #Z order of shake effect's boundary
  
  def initialize
		$state=self
		reset
    @scx=@scy=0
    @removed=[]
    @camera=Camera.new(0,0)
    
    @map=Map.new("CptnSapphire Map") #make a map
    @player=CptnSapphire.new(256,768) #make a player
    
    set_camera(Camera.new(@player.x, @player.y)) #make a new camera at player position
    @camera.follow(@player,8) #follow the player, by setting him as target entity ; 8 is speed of movement, remove it for instant following
    @camera.boundary(0,0,@map.width,@map.height) #set camera boundary to map's boundary ; camera can't cross given values from any side
    
    @flashr=Flasher.new([@player],2) #flash only player
    @flashr.remove #disable it for now
    
    @timeout=Timer.new(4500)
    
    @shifter=Mover.new(@entities[0].select{|ent| ent.class==CollectibleGem},0,0.1) #make a gem-moving thing
    
    @slowmo=Delayer.new(@entities[0]-[@camera],4) #delay all entities, excluding camera
    @slowmo.remove
  end
  
  def update
		@entities[0].each {|ent| ent.update if ent.respond_to?(:update) and !ent.stop and !ent.removed}
    
    @removed.each{|ent| @entities.each{|grp| grp.delete(ent)}}
    @removed.clear
    
    if Keypress[KbSpace,false] #start slowmotion if Space is pressed
      @slowmo.init
    elsif !Keypress[KbSpace] #stop slowmo
      @slowmo.remove
    end
    
    if Keypress[KbLeftControl,false] #start flashing if Control is pressed
      @flashr.init
    elsif !Keypress[KbLeftControl] #stop flashing
      @flashr.remove
    end
    
    @entities[0].delete_if{|ent| ent.class==CollectibleGem} if @timeout.finished #remove gems if time is out
  end
  
  def draw
    Img['Space'].draw(0,0,0) #draw background
    
    $screen.translate(-@camera.pos_x,-@camera.pos_y) do
      @entities[0].each {|ent| ent.draw if ent.respond_to?(:draw) and !ent.invisible and !ent.removed}
    end
    
    if @flash
      alpha=(@flash[0].alpha+(@flash[2] ? @flash[1] : -@flash[1]))
      if @flash[2] and alpha>255
        @flash[2]=nil
        @flash[0].alpha=255
      elsif !@flash[2] and alpha<0
        @flash=nil
      end
      @flash[0].alpha=alpha if @flash
      $screen.draw_quad(0,0,@flash[0],$screen.width,0,@flash[0],$screen.width,$screen.height,@flash[0],0,$screen.height,@flash[0],3) if @flash
    end
    
    Fnt[FONT,20].draw(@timeout.image(false),0,0,4) #draw the timer ; Timer.image returns string with a nice representations and you can select, which values you want to see
  end

	def solid?(x,y,down=true)
	end
  
  def flash(color,speed,starting=nil)
    clr=(color.class==Color ? color : Color.new(color))
    @flash=[clr,speed,starting]
  end
  
	def shake(max,time,num)
		@camera.shake(max,time,num)
	end

	def reset
		@entities=[[]] ; 1.times{@entities<<[]} #change #.times to number of defined groups
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
  
  def flashing? ; @flash end
end