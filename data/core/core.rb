#system class that controls pretty everything
class System
  attr_reader :keys
  attr_reader :music,:images,:tiles,:sounds,:fonts
  attr_writer :gui
  attr_accessor :premusic,:light_shader,:button_down,:button_up
  def initialize
    @keys={}
    @music={}
    @images={}
    @tiles={}
    @sounds={}
    @fonts={}
  end
  
  def update
    Msc[@premusic[1]].play(true) if @premusic and !@premusic[0].playing? and !@premusic[0].paused?
    GUI::System.Update if @gui
  end
  
  def draw
    GUI::System.Draw if @gui
    @button_down = @button_up = nil
  end
  
  def key_name(id)
    unless defined? @button_names
      button_constants = Gosu.constants(false)
      .grep(/^(?:Gp|Kb|Ms)/)
      .inject({}) { |h, k| h.merge! Gosu.const_get(k) => k }
      
      @button_names = Hash.new do |names, id|
      ch = $screen.button_id_to_char id
      names[id] = (ch and ch.ord > 0x20) ? ch.upcase : button_constants[id]
      end
    end
    @button_names[id].to_s.gsub("Kb","")
  end
end
$sapphire_system=System.new

#methods making system actually functional
def gui(value)
  $sapphire_system.gui=value
end

def key_press(id = true)
  raise "Expecting Symbol or Gosu::Button or true" if id.class != Symbol and id.class != Fixnum and id != true
  key = (id.class == Symbol ? $sapphire_system.keys[id] : id)
  return $sapphire_system.button_down if $sapphire_system.button_down == key or id == true && $sapphire_system.button_down
end

def key_release(id = true)
  raise "Expecting Symbol or Gosu::Button or true" if id.class != Symbol and id.class != Fixnum and id != true
  key = (id.class == Symbol ? $sapphire_system.keys[id] : id)
  return $sapphire_system.button_up if $sapphire_system.button_up == key or id == true && $sapphire_system.button_up
end

def key_hold(id)
  raise "Expecting Symbol or Gosu::Button" if id.class != Symbol and id.class != Fixnum
  key = (id.class == Symbol ? $sapphire_system.keys[id] : id)
  $screen.button_down? key
end

def bind_keys(keys={})
  raise "Expecting Symbol => Gosu::Button hash" if keys.keys.find{|key| key.class != Symbol} or keys.values.find{|value| value.class != Fixnum}
  keys.each_pair{|key,value| $sapphire_system.keys[key]=value}
end

def key_bound(id)
  raise "Expecting Symbol" if id.class != Symbol
  $sapphire_system.keys[id]
end

def key_name(id)
  raise "Expecting Gosu::Button" if id.class != Fixnum
  $sapphire_system.key_name(id)
end

def msc(name)
  if !$sapphire_system.music[name.downcase]
    dir=((Dir.exists?(file="data/music/#{name.split('/')[0]}") or File.exists?(file+'.ogg')) ? '/music' : '')
    $sapphire_system.music[name.downcase] = Song.new($screen, "data#{dir}/#{name}.ogg")
  end
  
  $sapphire_system.music[name.downcase]
end

def loop_music(name)
  dir=((Dir.exists?(file="data/music/#{name.split('/')[0]}") or File.exists?(file+'.ogg')) ? '/music' : '')
  pre=File.exists?("data#{dir}/#{name}-pre.ogg")
  
  $sapphire_system.premusic=nil
  if pre
    $sapphire_system.premusic=[msc(name), name]
    name+='-pre' if pre
  end
  
  msc(name).play(!pre)
end

def stop_music
  Song.current_song.stop if Song.current_song
  $sapphire_system.premusic=nil
end

def pause_music
  Song.current_song.pause if Song.current_song
end

def resume_music
  Song.current_song.play($sapphire_system.premusic[0] != Song.current_song) if Song.current_song
end

def img(name, tileable=false)
  if !$sapphire_system.images[name.downcase]
    dir=((Dir.exists?(file="data/gfx/#{name.split('/')[0]}") or File.exists?(file+'.png')) ? '/gfx' : '')
    $sapphire_system.images[name.downcase] = Image.new($screen, "data#{dir}/#{name}.png", tileable)
  end
  $sapphire_system.images[name.downcase]
end

def tls(name, width, height = width, tileable=false)
  if !$sapphire_system.tiles["#{name.downcase}_#{width}_#{height}"]
    dir=((Dir.exists?(file="data/gfx/#{name.split('/')[0]}") or File.exists?(file+'.png')) ? '/gfx' : '')
    $sapphire_system.tiles["#{name.downcase}_#{width}_#{height}"] = Image.load_tiles($screen, img(name), width, height, tileable)
  end
  $sapphire_system.tiles["#{name.downcase}_#{width}_#{height}"]
end

def snd(name)
  if !$sapphire_system.sounds[name.downcase]
    dir=((Dir.exists?(file="data/sfx/#{name.split('/')[0]}") or File.exists?(file+'.ogg')) ? '/sfx' : '')
    $sapphire_system.sounds[name.downcase] = Sample.new($screen, "data#{dir}/#{name}.ogg")
  end
  $sapphire_system.sounds[name.downcase]
end

def fnt(name, size=[])
  if size.class==Array
    if !$sapphire_system.fonts[name[0].downcase]
      raise "Bitmap font #{name} not initialized!" if size.empty?
      $sapphire_system.fonts[name[0].downcase] = BitmapFont.new(name, size)
    end
    $sapphire_system.fonts[name[0].downcase]
  else
    if !$sapphire_system.fonts["#{name.downcase}_#{size}"]
      $sapphire_system.fonts["#{name.downcase}_#{size}"] = Font.new($screen, name, size)
    end
    $sapphire_system.fonts["#{name.downcase}_#{size}"]
  end
end

class BitmapFont
  DFACTOR = 1 #scale of downcase characters
	def initialize(images,characters)
		@images,@characters=images,characters
	end

	def draw(text,x,y,z,args={})
		posx=posy=0
		scalex=(args[:scalex] ? args[:scalex] : 1)
		scaley=(args[:scaley] ? args[:scaley] : 1)
		xspacing=(args[:xspacing] ? args[:xspacing] : @images[1]*scalex)
		yspacing=(args[:yspacing] ? args[:yspacing] : @images[1]*scaley)
		max=args[:max]
		align=args[:align] ##multiline align unsupported (yet?) ##może each_line
		
    text=text.to_s
		text.each_char{|char| index=@characters.index(char.upcase)
    scalex1=(char.upcase==char ? scalex : scalex*DFACTOR)
    scaley1=(char.upcase==char ? scaley : scaley*DFACTOR)
		tls(*@images)[index].draw(x+posx-(align==:right ? (text.length*xspacing) : align==:center ? (text.length*xspacing)/2 : 0),y+posy+(scaley1 != scaley ? yspacing*(1-DFACTOR) : 1),z,scalex1,scaley1,args[:color] ? args[:color] : 0xffffffff) if index
		posx+=xspacing
		(posy+=yspacing ; posx=0) if char=="\n" or max && posx+xspacing>max}
	end
end

#some other classes
class Entity
	attr_accessor :x,:y,:_no_update,:_no_draw
  attr_reader :_removed,:_spawn_time,:_tags
	def init(*tags)
    @_tags=tags
    @_spawn_time=$time
    @_removed=false
    
		$state.add(self)
	end

	def remove
    @collider.remove if @collider
    $state.remove(self)
    @_removed=true
	end

	def gravity(width,height=width,gravity=1)
		@vy||=0
		@vy+=gravity
		if @vy>0
			@vy.to_i.times{if !$state.solid?(@x,@y+height,true) and !$state.solid?(@x+width,@y+height,true) ; @y+=1 else @vy=0 end}
		elsif @vy<0
			(-@vy).to_i.times{if !$state.solid?(@x,@y,true) and !$state.solid?(@x+width,@y,true) ; @y-=1 else @vy=0 end}
		end
	end
    
  def life_time
    $time-@_spawn_time
  end
end

class State
  attr_accessor :lighting_enabled
  attr_reader :entities,:camera,:lights,:collisions
  
  FLASH_Z=5
  SHAKE_Z=5
  DARK_Z=5
  def groups ; [] end
  
  def initialize(*args)
		$state=self
		reset
    @lights=[]
    @camera=Camera.new($screen.width/2,$screen.height/2)
    @dark=Ashton::WindowBuffer.new if USE_ASHTON
    @collisions=Collision_Manager.new if USE_CHIPMUNK 
    
    setup(*args)
  end
  
  def update
    @collisions.update if USE_CHIPMUNK
    pre
    
		@entities.reject! do |ent|
      ent.update if ent.respond_to?(:update) and !ent._no_update
      ent._removed
    end
    
    post
  end
  
  def draw
    if @darkness_level
      @dark.render{ Img['core/Dark'].draw(0,0,0,1,1,0xff000000)
      Img['core/Dark'].draw(0,0,0,1,1,Color.new(255-@darkness_level,255-@darkness_level,255-@darkness_level),:additive)
      @lights.each{|light| $sapphire_system.light_shader.Value=light.luminance/255.0
      Img['core/Light'].draw_rot(light.x - @camera.pos_x,light.y - @camera.pos_y,0,0,0.5,0.5,light.radius/256.0,light.radius/256.0,light.color,:additive,:shader=>$sapphire_system.light_shader)}}
    end
    
    back
    
    $screen.translate(-@camera.pos_x,-@camera.pos_y) do
      if @camera.shader?
        $screen.post_process @camera.shader? do
          @entities.each {|ent| ent.draw if ent.respond_to?(:draw) and !ent._no_draw}
        end
      else
        @entities.each {|ent| ent.draw if ent.respond_to?(:draw) and !ent._no_draw}
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
        $screen.draw_quad(0,0,@flash[0],$screen.width,0,@flash[0],$screen.width,$screen.height,@flash[0],0,$screen.height,@flash[0],self.class::FLASH_Z)
      end
    end
    
    if @darkness_level
      @dark.draw(0,0,self.class::DARK_Z,:mode=>:multiply)
    end
    
    $screen.flush
    front
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
		@entities=[]
    @groups=[[]]*groups.length
    @camera.init if @camera
	end
  
  def find(group=0)
    @entities.find{|ent| yield(ent)}
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
    self.class::SHAKE_Z
  end
  
  def play(sample,x,y,volume=$screen.width*2,speed=1)
    scx=@camera.pos_x+$screen.width/2
    scy=@camera.pos_y+$screen.height/2
    unit=volume.to_i/10
    pan=10*((x-scx).abs.to_i/unit)*0.01*(x<=>scx)
    Snd[sample].play_pan(pan,[(volume-distance(scx,scy,x,y))*2/volume,0].max)
  end
  
  def add(entity)
    @entities << entity
    @groups.each_index{|i|
      @groups[i] << entity if !(groups[i] & entity._tags).empty?
    }
  end
  
  def remove(entity)
    @groups.each{|group| group.delete(entity)}
  end
  
  def setup ; end
  def pre ; end
  def post ; end
  def back ; end
  def front ; end
end