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
    
    $enable_gui=true #enable using GUI
    
    @window=GUI::Window.new(0,0,160,240,"Properites",#create window, below are objects
    [:text,"Type",0,0],#the :text is one of customisations, it just shows text
    [:text,"X position",0,50],
    [:text,"Y position",0,100],
    [:text,"Scale",0,150],
    [:text,"Red",0,205],
    [:object,:type,GUI::Dropdown.new(20,25,"Square","Circle","Triangle")],#to make another GUI element into window, use :object, give it name and the last thing is this object. Object's position will be relative to GUI window, not absolute.
    [:object,:pos_x,GUI::Number.new(20,75,0,640)],
    [:object,:pos_y,GUI::Number.new(20,125,0,480)],
    [:object,:scale,GUI::Zip.new(20,190,30,4)],
    [:object,:red,GUI::Check.new(40,205)]
    )
    @window.disabled=true #make window invisible
    
    @new=GUI::Button.new(0,456,"Add shape") #make a maker-button
  end
  
  def update
		@entities[0].each {|ent| ent.update if ent.respond_to?(:update) and !ent.stop and !ent.removed}
    
    @removed.each{|ent| @entities.each{|grp| grp.delete(ent)}}
    @removed.clear
    
    if @new.value #if button was pressed
      Shape.new
    end
    
    if Keypress[MsLeft,false] and !@select and obj=find{|obj| obj.class==Shape and distance(obj.x,obj.y,$screen.mouse_x,$screen.mouse_y)<16} #check if some object was selected
      @select=obj #put object into variable for later interactions
      
      @window.disabled=false #visible the window
      @window.set_value(:type,obj.type) #set value of object named :type (it was Dropbox as seen above)
      @window.set_value(:pos_x,obj.x)
      @window.set_value(:pos_y,obj.y)
      @window.set_value(:scale,obj.scale)
      @window.set_value(:red,obj.red)
    elsif @select
      @select.type=@window.value(:type) #retrieve the value from :type
      @select.x=@window.value(:pos_x)
      @select.y=@window.value(:pos_y)
      @select.scale=@window.value(:scale)
      @select.red=@window.value(:red)
    end
      
    if Keypress[MsRight,false]
      @window.disabled=true #invisible the window and deselect object
      @select=nil
    end
  end
  
  def draw
    if @lighting_enabled
      @dark.render{ Img['core/Dark'].draw(0,0,0)
      @lights.each{|light| Tls['core/Light',256][light.luminance-1].draw_rot(light.x - @camera.pos_x,light.y - @camera.pos_y,0,0,0.5,0.5,light.radius/256.0,light.radius/256.0,light.color,:additive)}}
    end
    @lights.clear
    
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
      $screen.draw_quad(0,0,@flash[0],$screen.width,0,@flash[0],$screen.width,$screen.height,@flash[0],0,$screen.height,@flash[0],FLASH_Z) if @flash
    end
    
    if @lighting_enabled
      @dark.draw(0,0,DARK_Z,:mode=>:multiply)
    end
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
end
