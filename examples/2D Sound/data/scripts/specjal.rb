class Keypress
  @@pressing=[[],[]]
  @@keys={}
	def Keypress.[](id,repeat=true)
		@@keys = [] unless defined?(@@keys)
    key=(id.class==Symbol ? @@keys[id] : id)
    if repeat
      $screen.button_down?(key)
    else
      ($screen.button_down?(key) and !@@pressing[0].include?(key))
    end
	end
  
  def Keypress.Push(id)
    @@pressing[1] << id
  end
  
  def Keypress.Remove(id)
    @@pressing[0].delete(id)
  end
  
  def Keypress.Clean
    @@pressing[1].each{|key| @@pressing[0] << key}
    @@pressing[1].clear
  end
  
  def Keypress.Define(keys={})
    @@keys=keys
  end
  
  def Keypress.Set(key,new)
    @@keys[key]=new
  end
  
  def Keypress.Any
    @@pressing[1].last
  end
end

class Img
  def Img.[](name,tileable=false)
    @@images = Hash.new unless defined?(@@images)
    if @@images[name.downcase]
      @@images[name.downcase]
    else
			dir=((Dir.exists?(file="data/gfx/#{name.split('/')[0]}") or File.exists?(file+'.png')) ? '/gfx' : '')
      @@images[name.downcase] = Image.new($screen, "data#{dir}/#{name}.png", tileable)
    end
  end

	def Img.reset
		@@images.clear
	end
end

class Tls
  def Tls.[](name,width,height=width,tileable=false)
		size=[width,height]
    @@tiles = Hash.new unless defined?(@@tiles)
    if @@tiles[[name.downcase,size]]
      @@tiles[[name.downcase,size]]
    else
			dir=((Dir.exists?(file="data/gfx/#{name.split('/')[0]}") or File.exists?(file+'.png')) ? '/gfx' : '')
      @@tiles[[name.downcase,size]] = Image.load_tiles($screen, "data#{dir}/#{name}.png", width, height, tileable)
    end
  end

	def Tls.reset
		@@tiles.clear
	end
end

class Snd
  def Snd.[](name)
    @@sounds = Hash.new unless defined?(@@sounds)
    if @@sounds[name.downcase]
      @@sounds[name.downcase]
    else
			dir=((Dir.exists?(file="data/sfx/#{name.split('/')[0]}") or File.exists?(file+'.ogg')) ? '/sfx' : '')
      @@sounds[name.downcase] = Sample.new($screen, "data#{dir}/#{name}.ogg")
    end
  end

	def Snd.reset
		@@sounds.clear if defined?(@@sounds)
	end
end

class Msc
  def Msc.[](name,pre=nil)
    @@music = Hash.new unless defined?(@@music)
    if pre==:auto
			dir=((Dir.exists?(file="data/music/#{name.split('/')[0]}") or File.exists?(file+'.ogg')) ? '/music' : '')
      pre=File.exists?("data#{dir}/#{name}-pre.ogg")
    end
    Msc[name] if pre
    name+='-pre' if pre
    if !@@music[name.downcase]
			dir=((Dir.exists?(file="data/music/#{name.split('/')[0]}") or File.exists?(file+'.ogg')) ? '/music' : '')
      @@music[name.downcase] = Song.new($screen, "data#{dir}/#{name}.ogg")
    end
    $premusic=nil
    $premusic=[@@music[name.downcase],name.chomp('-pre')] if pre
    @@music[name.downcase]
  end

	def Msc.reset
		@@music.clear if defined?(@@music)
	end
end

class Fnt
  def Fnt.[](name,size=[])
    @@fonts = Hash.new unless defined?(@@fonts)
		if name.class==Array
      name[0].downcase!
			if @@fonts[name]
				@@fonts[name]
			else
				@@fonts[name] = BitmapFont.new(name,size)
			end
		else
			if @@fonts[[name.downcase,size]]
				@@fonts[[name.downcase,size]]
			else
				@@fonts[[name.downcase,size]] = Font.new($screen, name, size)
			end
		end
  end

	def Fnt.reset
		@@fonts.clear
	end
end

class BitmapFont
	NEW_LINE='^' #this character will make new line
  DFACTOR=1 #scale of downcase characters
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
		align=args[:align] ##multiline align unsupported
		
    text=text.to_s
		text.each_char{|char| index=@characters.index(char.upcase)
    scalex1=(char.upcase==char ? scalex : scalex*DFACTOR)
    scaley1=(char.upcase==char ? scaley : scaley*DFACTOR)
		Tls[*@images][index].draw(x+posx-(align==:right ? (text.length*xspacing) : align==:center ? (text.length*xspacing)/2 : 0),y+posy+(scaley1 != scaley ? yspacing*(1-DFACTOR) : 1),z,scalex1,scaley1,args[:color] ? args[:color] : 0xffffffff) if index
		posx+=xspacing
		(posy+=yspacing ; posx=0) if char==NEW_LINE or max && posx+xspacing>max}
	end
end

class Entity
	attr_accessor :x,:y,:stop,:invisible
  attr_reader :removed,:spawn_time
	def init(*types)
		$state.entities[0] << self
    $state.entities[1] << self if types.include?(:tile)
    #define additional groups like above
    
    @spawn_time=$time
	end

	def remove
    $state.remove(self)
    @removed=true
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
end

def Stop_Music
  Song.current_song.stop if Song.current_song
  $premusic=nil
end
