class Particle < Entity
	def initialize(x,y,z,img,vx,vy,args={})
		@x,@y,@z,@img,@args=x,y,z,img,args
		@vx=vx ; @vy=vy
    @args[:angle]=0 if @args[:rotate] and !@args[:angle]
		init
	end
	
	def update
		@x+=@vx ; @y+=(@vy+=1)
    @args[:angle]+=@args[:rotate] if @args[:rotate]
		remove if @y>$state.camera.pos_y+$screen.height
	end

	def draw
    img=(@img.class == Array ? tls(@img[0], @img[1], @img[2])[@img[3]] : img(@img))
    if @args[:angle]
      img.draw_rot(@x,@y,@z,@args[:angle],0.5,0.5,@args[:scalex] ? @args[:scalex] : 1,@args[:scaley] ? @args[:scaley] : 1,@args[:color] ? @args[:color] : 0xffffffff)
    else
      img.draw(@x,@y,@z,@args[:scalex] ? @args[:scalex] : 1,@args[:scaley] ? @args[:scaley] : 1,@args[:color] ? @args[:color] : 0xffffffff)
    end
	end
end

class Trail < Entity
	def initialize(x,y,z,tiles,time,args={})
		@x,@y,@z,@tiles,@time,@args=x,y,z,tiles,time,args
    @sequence=(@args[:sequence] ? @args[:sequence] : (0...(tls(@tiles[0], @tiles[1], @tiles[2]).length)).to_a)
    @frame=0
		init
	end

	def update
    @delay||=Timer.new(@time)
    if @delay.finished
      if (@frame+=1)==@sequence.length
        if @args[:repeat] and @args[:repeat]>0
          @args[:repeat]-=1
          @frame=0
        else
          remove
        end
      end
      @delay=nil
    end
	end

	def draw
    tls(@tiles[0], @tiles[1], @tiles[2])[@sequence[@frame]].draw(@x,@y,@z,@args[:scalex] ? @args[:scalex] : 1,@args[:scaley] ? @args[:scaley] : 1,@args[:color] ? @args[:color] : 0xffffffff)
	end
end

class Trace < Entity
	def initialize(x,y,z,img,speed,args={})
		@x,@y,@z,@img,@speed,@args=x,y,z,img,speed,args
		@color=(args[:color] ? args[:color] : Color.new(0xffffffff))
		init
	end

	def update
		@color.alpha=[@color.alpha-@speed,0].max
		remove if @color.alpha==0
	end

	def draw
    @color.alpha=255-@color.alpha if @args[:inverted]
    img=(@img.class == Array ? tls(@img[0], @img[1], @img[2])[@img[3]] : img(@img))
    if @args[:angle]
      img.draw_rot(@x,@y,@z,@args[:angle],0.5,0.5,@args[:scalex] ? @args[:scalex] : 1,@args[:scaley] ? @args[:scaley] : 1,@color)
    else
      img.draw(@x,@y,@z,@args[:scalex] ? @args[:scalex] : 1,@args[:scaley] ? @args[:scaley] : 1,@color)
    end
    @color.alpha=255-@color.alpha if @args[:inverted]
	end
end

class Light
  attr_accessor :x,:y,:radius,:color,:luminance
  def initialize(x,y,radius,color=0xffffffff,luminance=1)
    @x,@y,@radius,@color,@luminance=x,y,radius,color,luminance
    on
  end
  
  def on
    $state.lights << self if !@on
    @on=true
  end
  
  def off
    $state.lights.delete(self) if @on
    @on=false
  end
end