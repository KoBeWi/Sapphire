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
	def initialize(x,y,z,tiles,time,args={})
		@x,@y,@z,@tiles,@time,@args=x,y,z,tiles,time,args
    @sequence=(@args[:sequence] ? @args[:sequence] : (0...(Tls[@tiles[0], @tiles[1], @tiles[2]].length)).to_a)
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
    @color.alpha=255-@color.alpha if @args[:inverted]
    if @args[:angle]
      img.draw_rot(@x,@y,@z,@args[:angle],0.5,0.5,@args[:scalex] ? @args[:scalex] : 1,@args[:scaley] ? @args[:scaley] : 1,@color)
    else
      img.draw(@x,@y,@z,@args[:scalex] ? @args[:scalex] : 1,@args[:scaley] ? @args[:scaley] : 1,@color)
    end
    @color.alpha=255-@color.alpha if @args[:inverted]
	end
end

class Combo < Entity
  attr_reader :trigger
  def initialize(timeout,*sequence)
    @timeout,@sequence=timeout,sequence
    @sequence.collect!{|key| if key.class==Symbol then $keys[key] else key end}
    @combo=[]
    @time=0
    init
  end
  
  def update
    @time+=1
    if Keypress.Any
      @combo << Keypress.Any
      @time=0
    end
    @combo.clear if @time==@timeout
    
    if @trigger
      @trigger=nil
      @combo.clear
    end
    @trigger=true if @combo.reverse.take(@sequence.length)==@sequence.reverse
  end
end

class Vector
  attr_reader :x,:y
  def initialize(x,y)
    @x,@y=x.to_f,y.to_f
  end
end

class Collision_Box
  attr_reader :x,:y,:w,:h,:a,:vectors
  attr_writer :w,:h
  def initialize(x,y,w,h,a)
    @x,@y,@w,@h,@a=x,y,w,h,(180-a)
    set_vectors
  end
    
  def collides?(col)
    return if col==self
    
    if col.class==Collision_Box
      4.times{|i|
        axis=Vector.new(@vectors[1].x-@vectors[0].x, @vectors[1].y-@vectors[0].y) if i==0
        axis=Vector.new(@vectors[1].x-@vectors[2].x, @vectors[1].y-@vectors[2].y) if i==1
        axis=Vector.new(col.vectors[0].x-col.vectors[3].x, col.vectors[0].y-col.vectors[3].y) if i==2
        axis=Vector.new(col.vectors[0].x-col.vectors[1].x, col.vectors[0].y-col.vectors[1].y) if i==3
        
        values1=[]
        values2=[]
        4.times{|p|
        values1 << ((@vectors[p].x * axis.x + @vectors[p].y * axis.y) / (axis.x ** 2 + axis.y ** 2))* axis.x ** 2 + ((@vectors[p].x * axis.x + @vectors[p].y * axis.y) / (axis.x ** 2 + axis.y ** 2)) * axis.y ** 2
        values2 << ((col.vectors[p].x * axis.x + col.vectors[p].y * axis.y) / (axis.x ** 2 + axis.y ** 2))* axis.x ** 2 + ((col.vectors[p].x * axis.x + col.vectors[p].y * axis.y) / (axis.x ** 2 + axis.y ** 2))* axis.y ** 2
        }
        
        return if not values2.min<=values1.max && values2.max>=values1.min
      }
      true
    elsif col.class== Collision_Ball
      a=Math::PI*(@a/180.0)
      x = Math.cos(a) * (col.x - @x) - Math.sin(a) * (col.y - @y) + @x
      y = Math.sin(a) * (col.x - @x) + Math.cos(a) * (col.y - @y) + @y
      
      if x < @x - @w/2
        cx = @x - @w/2
      elsif x > @x + @w/2
        cx = @x + @w/2
      else
        cx = x
      end
      
      if y < @y - @h/2
        cy = @y - @h/2
      elsif y > @y + @h/2
        cy = @y + @h/2
      else
        cy = y
      end
      
      distance(x,y,cx,cy)<col.r
    elsif col.class==Collision_Group
      col.collides?(self)
    end
  end
  
  def set(x,y,a=@a)
    @x,@y,@a=x,y,a
    set_vectors
  end
  
  def move(x=0,y=0,a=0)
    @x+=x
    @y+=y
    @a-=a
    set_vectors
  end
  
  def set_vectors
    d=Math.sqrt(@w**2+@h**2)/2
    a=Math::PI*(angle(0,0,@w,@h)/180.0)
    a1=Math::PI*(@a/180.0)
    @vectors=[Vector.new(@x+Math.sin(a1-a)*d,@y+Math.cos(a1-a)*d),
    Vector.new(@x+Math.sin(a1+a)*d,@y+Math.cos(a1+a)*d),
    Vector.new(@x+Math.sin(a1+Math::PI-a)*d,@y+Math.cos(a1+Math::PI-a)*d),
    Vector.new(@x+Math.sin(a1+Math::PI+a)*d,@y+Math.cos(a1+Math::PI+a)*d)]
  end
end

class Collision_Ball
  attr_reader :x,:y,:r
  attr_writer :r
  def initialize(x,y,r)
    @x,@y,@r=x,y,r
  end
  
  def collides?(col)
    return if col==self
    if col.class==Collision_Box
      a=Math::PI*(col.a/180.0)
      x = Math.cos(a) * (@x - col.x) - Math.sin(a) * (@y - col.y) + col.x
      y = Math.sin(a) * (@x - col.x) + Math.cos(a) * (@y - col.y) + col.y
      
      if x < col.x - col.w/2
        cx = col.x - col.w/2
      elsif x > col.x + col.w/2
        cx = col.x + col.w/2
      else
        cx = x
      end
      
      if y < col.y - col.h/2
        cy = col.y - col.h/2
      elsif y > col.y + col.h/2
        cy = col.y + col.h/2
      else
        cy = y
      end
      
      distance(x,y,cx,cy)<@r
    elsif col.class== Collision_Ball
      distance(@x,@y,col.x,col.y)<@r+col.r
    elsif col.class==Collision_Group
      col.collides?(self)
    end
  end
  
  def set(x,y)
    @x,@y=x,y
  end
  
  def move(x=0,y=0)
    @x+=x
    @y+=y
  end
end

class Collision_Group
  attr_reader :x,:y,:a,:c
  def initialize(x,y,a,*c)
    @x,@y,@a,@c=x,y,(180-a),c
  end
  
  def collides?(col)
    return if col==self
    if col.class==Collision_Group
      return true if @c.find{|c| col.find{|c2| c2.collides?(c)}}
    else
      return true if @c.find{|c| c.collides?(col)}
    end
  end
  
  def set(x,y,a=@a)
    @c.each{|c| c.class==Collission_Ball ? c.move(x-@x,y-@y) : c.move(x-@x,y-@y,a-@a)}
    @x,@y,@a=x,y,a
  end
  
  def move(x=0,y=0,a=0)
    @c.each{|c| c.class==Collission_Ball ? c.move(x,y) : c.move(x,y,a)}
    @x+=x
    @y+=y
    @a+=a
  end
end