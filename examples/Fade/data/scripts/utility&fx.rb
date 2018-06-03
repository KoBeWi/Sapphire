class Timer < Entity
  attr_reader :finished,:time
  def initialize(time)
    @time=time
    init
  end

  def update
    if (@time-=1)==0
      @finished=true
      remove
    end
  end

  def image(h=true,m=true,s=true,hs=true)
    txt=[]
    txt << "#{'0' if (t=(@time/216000%60).to_i)<10}#{t}" if h
    txt << "#{'0' if (t=(@time/3600%60).to_i)<10}#{t}" if m
    txt << "#{'0' if (t=(@time/60%60).to_i)<10}#{t}" if s
    txt << "#{'0' if (@time/0.6)%100<10}#{((@time/0.6)%100).to_i}" if hs
    txt.join(':')
  end
end

class Mover < Entity
  attr_reader :entities
  def initialize(entities,xspeed,yspeed)
    @entities,@xspeed,@yspeed=entities,xspeed,yspeed
    init
  end

  def update
    @entities.each{|ent| ent.x+=@xspeed ; ent.y+=@yspeed}
  end
end

class Flasher < Entity
  attr_reader :entities
  def initialize(entities,time1,time2=time1)
    @entities,@time1,@time2=entities,time1,time2=time1
    init
  end

  def update
    (@delay=Timer.new(@time ? @time2 : @time1) ; @time=!@time) if !@delay
    if @delay.finished
      @entities.each{|ent| ent.invisible=!ent.invisible}
      @delay=nil
    end
  end
end

class Delayer < Entity
  attr_reader :entities
  def initialize(entities,time)
    @entities,@time=entities,time
    init
  end

  def update
    (@delay=Timer.new(@time) ; @entities.each{|ent| ent.stop=true}) if !@delay
    if @delay.finished
      @entities.each{|ent| ent.stop=@delay=nil}
    end
  end
end

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
		remove if @y>$game.scy+$screen.height
	end

	def draw
    img=(@img.class == Array ? Tls[@img[0], @img[1], @img[2]][@img[3]] : Img[@img])
    if @args[:angle]
      img.draw_rot(@x,@y,@z,@args[:angle],0.5,0.5,@args[:scalex] ? @args[:scalex] : 1,@args[:scaley] ? @args[:scaley] : 1,@args[:color] ? @args[:color] : 0xffffffff)
    else
      img.draw(@x,@y,@z,@args[:scalex] ? @args[:scalex] : 1,@args[:scaley] ? @args[:scaley] : 1,@args[:color] ? @args[:color] : 0xffffffff)
    end
	end
end

class Trail < Entity
	def initialize(x,y,z,tiles,sequence,time,args={})
		@x,@y,@z,@tiles,@sequence,@time,@args=x,y,z,tiles,sequence,time,args
    @frame=0
		init
	end

	def update
    @delay||=Timer.new(@time)
    if @delay.finished
      remove if (@frame+=1)==@sequence.length
      @delay=nil
    end
	end

	def draw
    Tls[@tiles[0], @tiles[1], @tiles[2]][@sequence[@frame]].draw(@x,@y,@z,@args[:scalex] ? @args[:scalex] : 1,@args[:scaley] ? @args[:scaley] : 1,@args[:color] ? @args[:color] : 0xffffffff)
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
    img=(@img.class == Array ? Tls[@img[0], @img[1], @img[2]][@img[3]] : Img[@img])
    if @args[:angle]
      img.draw_rot(@x,@y,@z,@args[:angle],0.5,0.5,@args[:scalex] ? @args[:scalex] : 1,@args[:scaley] ? @args[:scaley] : 1,@color)
    else
      img.draw(@x,@y,@z,@args[:scalex] ? @args[:scalex] : 1,@args[:scaley] ? @args[:scaley] : 1,@color)
    end
	end
end
