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
    
    @combo=Combo.new(15,:up,:up,:down,:down,:left,:right,:left,:right,:b,:a) #create combo
    
    #textboxes for input
    @up=GUI::Textbox.new(0,312,16) ; @up.value="KbUp"
    @left=GUI::Textbox.new(0,336,16) ; @left.value="KbLeft"
    @right=GUI::Textbox.new(0,360,16) ; @right.value="KbRight"
    @down=GUI::Textbox.new(0,384,16) ; @down.value="KbDown"
    @a=GUI::Textbox.new(0,408,16) ; @a.value="KbLeftControl"
    @b=GUI::Textbox.new(0,432,16) ; @b.value="KbLeftShift"
    
    #buttons for input deffining
    @set_up=GUI::Button.new(192,312,"Set Up")
    @set_left=GUI::Button.new(192,336,"Set Left")
    @set_right=GUI::Button.new(192,360,"Set Right")
    @set_down=GUI::Button.new(192,384,"Set Down")
    @set_a=GUI::Button.new(192,408,"Set A")
    @set_b=GUI::Button.new(192,432,"Set B")
    
    $enable_gui=true
  end
  
  def update
		@entities[0].each {|ent| ent.update if ent.respond_to?(:update) and !ent.stop and !ent.removed}
    
    @removed.each{|ent| @entities.each{|grp| grp.delete(ent)}}
    @removed.clear
    
    @cmb=!@cmb if @combo.trigger #if combo is finished
    @key1=!@key1 if Keypress.Any #any key is pressed
    @key2= Keypress[:up] #up is being pressed ; it's a key named :up not actual KbUp. You can bind a different key
    @key3= !Keypress[:down]
    @key4= Keypress[:left,false] #left is just pressed
    
    #define keys
    Keypress.Set(:up, Kernel.const_get(@up.value.to_sym)) if @set_up.value
    Keypress.Set(:left, Kernel.const_get(@left.value.to_sym)) if @set_left.value
    Keypress.Set(:right, Kernel.const_get(@right.value.to_sym)) if @set_right.value
    Keypress.Set(:down, Kernel.const_get(@down.value.to_sym)) if @set_down.value
    Keypress.Set(:a, Kernel.const_get(@a.value.to_sym)) if @set_a.value
    Keypress.Set(:b, Kernel.const_get(@b.value.to_sym)) if @set_b.value
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
      
      if @flash
        @flash[0].alpha=alpha
        $screen.draw_quad(0,0,@flash[0],$screen.width,0,@flash[0],$screen.width,$screen.height,@flash[0],0,$screen.height,@flash[0],FLASH_Z)
      end
    end
    
    if @lighting_enabled
      @dark.draw(0,0,DARK_Z,:mode=>:multiply)
    end
    #make some instructions
    Fnt[FONT,20].draw("The combo is: up up down down left right left right B A.  Be quick!",0,0,0)
    Tls['core/Check',24][@cmb ? 1 : 0].draw(24,24,0)
    
    Fnt[FONT,20].draw("This one switches if any key is pressed",0,48,0)
    Tls['core/Check',24][@key1 ? 1 : 0].draw(24,72,0)
    
    Fnt[FONT,20].draw("This one is green when holding Up",0,96,0)
    Tls['core/Check',24][@key2 ? 1 : 0].draw(24,116,0)
    
    Fnt[FONT,20].draw("This one is green when not holding Down",0,144,0)
    Tls['core/Check',24][@key3 ? 1 : 0].draw(24,164,0)
    
    Fnt[FONT,20].draw("This one is green when Left was just pressed",0,192,0)
    Tls['core/Check',24][@key4 ? 1 : 0].draw(24,212,0)
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
