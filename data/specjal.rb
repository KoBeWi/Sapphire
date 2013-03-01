class Keypress
	def Keypress.[](id,repeat=true)
		@@keys = [] unless defined?(@@keys)
    key=(id.class==Symbol ? $keys[id] : id)
    if repeat
      $screen.button_down?(key)
    elsif !$pressing[0].include?(key) and $screen.button_down?(key)
      $pressing[1] << key
      return true
    end
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
	NEW_LINE='^'
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
		align=args[:align] ##calculate line
		
    text=text.to_s
		text.each_char{|char| index=@characters.index(char.upcase)
		Tls[*@images][index].draw(x+posx-(align==:right ? (text.length*xspacing) : align==:center ? (text.length*xspacing)/2 : 0),y+posy,z,scalex,scaley,args[:color] ? args[:color] : 0xffffffff)
		posx+=xspacing
		(posy+=yspacing ; posx=0) if @characters[index]==NEW_LINE or max && posx+xspacing>max}
	end
end

class Entity
	attr_accessor :x,:y,:stop,:invisible
	def init(*types)
		$game.entities[0] << self
    $game.entities[1] << self if types.include?(:tile)
	end

	def remove
		$game.entities.each{|e| if e.class==Array
			e.delete(self) end}
		$game.entities.delete(self)
	end

	def gravity(width,height=width)
		@vy=0 if !@vy
		@vy+=1
		if @vy.to_i>0
			@vy.to_i.times{if !$game.solid?(@x,@y+height,true) and !$game.solid?(@x+width,@y+height,true) ; @y+=1 else @vy=0 end}
		elsif @vy.to_i<0
			(-@vy).to_i.times{if !$game.solid?(@x,@y,true) and !$game.solid?(@x+width,@y,true) ; @y-=1 else @vy=0 end}
		end
	end
end
