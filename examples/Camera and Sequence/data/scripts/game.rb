class Game
  attr_accessor :lighting_enabled
  attr_reader :entities,:camera,:lights,:map,:player
  
  FLASH_Z=6 #Z order of flash effect
  SHAKE_Z=7 #Z order of shake effect's boundary
  DARK_Z=5 #Z order of shadows
  GROUPS=1 #number of entity groups
  
  def initialize
		$state=self
		reset
    @scx=@scy=0
    @removed=[]
    @lights=[]
    # @camera=Camera.new(0,0)
    @dark=Ashton::WindowBuffer.new
    
    @map=Map.new("CptnSapphire Map")
    @player=CptnSapphire.new(256,768)
    
    set_camera(Camera.new(@player.x, @player.y))
    set_default_camera(@camera) #set this camera as default so it can be easily accessed later
    @camera.follow(player)
    @camera.boundary(0,0,@map.width,@map.height)
  end
  
  def update
		@entities[0].each {|ent| ent.update if ent.respond_to?(:update) and !ent.stop and !ent.removed}
    
    @removed.each{|ent| @entities.each{|grp| grp.delete(ent)}}
    @removed.clear
    
    #this is action defined in Game class, but you may define your actions map-specific etc. for more flexibility
    if @entities[1].length==0 and !@action
      @action=true #make sure it won't repeat
      tnt=find{|ent| ent.class==TNT} #search for entity passing given block
      Sequence.new [ #make an action sequence ; note that it's an array of hashes, not a block
      {:type=>:stop, :value=>true},#user-defined action to stop player's movement (go to utility&fx.rb line 540+ to define your actions)
      {:type=>:camera_move, :target=>[tnt.x,tnt.y,8]}, #first move the camera
      {:type=>:kill_tnt, :tnt=>tnt}, #another user-defined action, for killing tnt
      {:type=>:trail, :values=>[tnt.x-24,tnt.y-24,2,['Explosion',68,76],4],:skip=>true}, #make a trail ; arguments needed for constructor are in array ; :skip thing ommits waiting for trail to disappear before next action
      {:type=>:sample, :name=>'Explosion'}, #play sample of given name
      {:type=>:camera_follow, :target=>@player, :smooth=>8}, #return to following player
      {:type=>:camera_follow, :target=>@player}, #remove smooth following from camera
      {:type=>:stop, :value=>false}
      ]
    end
  end
  
  def draw
    if @lighting_enabled
      @dark.render{ Img['core/Dark'].draw(0,0,0)
      @lights.each{|light| Tls['core/Light',256][light.luminance-1].draw_rot(light.x - @camera.pos_x,light.y - @camera.pos_y,0,0,0.5,0.5,light.radius/256.0,light.radius/256.0,light.color,:additive)}}
    end
    @lights.clear
    
    Img['Space'].draw(0,0,0)
    
    $screen.translate(-@camera.pos_x,-@camera.pos_y) do
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
      @flash[0].alpha=alpha if @flash
      $screen.draw_quad(0,0,@flash[0],$screen.width,0,@flash[0],$screen.width,$screen.height,@flash[0],0,$screen.height,@flash[0],3) if @flash
    end
    
    if @lighting_enabled
      @dark.draw(0,0,DARK_Z,:mode=>:multiply)
    end
    
    Fnt[FONT,20].draw("Gems: #{@entities[1].length}",20,20,5) #all gems are in @entities[1] group array as well as in @entities[0] with all other objects ; note the Fnt class that returns font of given name and size
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
  
  def flashing? ; @flash end
end