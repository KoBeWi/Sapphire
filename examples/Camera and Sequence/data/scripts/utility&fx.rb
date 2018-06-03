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

class Collision_Box
  attr_reader :x,:y,:w,:h,:a,:vectors
  attr_writer :w,:h
  def initialize(x,y,w,h,a=0)
    @x,@y,@w,@h,@a=x,y,w,h,(180-a)
    set_vectors
  end
    
  def collides?(col)
    return if col==self
    
    if col.class==Collision_Box
      4.times{|i|
        if i==0
          axisx=@vectors[2]-@vectors[0]
          axisy=@vectors[3]-@vectors[1]
        elsif i==1
          axisx=@vectors[2]-@vectors[4]
          axisy=@vectors[3]-@vectors[5]
        elsif i==2
          axisx=col.vectors[0]-col.vectors[6]
          axisy=col.vectors[1]-col.vectors[7]
        elsif i==3
          axisx=col.vectors[0]-col.vectors[2]
          axisy=col.vectors[1]-col.vectors[3]
        end
        
        values1=[]
        values2=[]
        4.times{|p|
        values1 << ((@vectors[p*2] * axisx + @vectors[p*2+1] * axisy) / (axisx ** 2 + axisy ** 2)) * axisx ** 2 + ((@vectors[p*2] * axisx + @vectors[p*2+1] * axisy) / (axisx ** 2 + axisy ** 2)) * axisy ** 2
        values2 << ((col.vectors[p*2] * axisx + col.vectors[p*2+1] * axisy) / (axisx ** 2 + axisy ** 2))* axisx ** 2 + ((col.vectors[p*2] * axisx + col.vectors[p*2+1] * axisy) / (axisx ** 2 + axisy ** 2))* axisy ** 2
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
    @vectors=[@x+Math.sin(a1-a)*d, @y+Math.cos(a1-a)*d, @x+Math.sin(a1+a)*d, @y+Math.cos(a1+a)*d, @x+Math.sin(a1+Math::PI-a)*d, @y+Math.cos(a1+Math::PI-a)*d, @x+Math.sin(a1+Math::PI+a)*d, @y+Math.cos(a1+Math::PI+a)*d]
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
    a=-(180-a)
    @c.each{|c| c.class==Collision_Ball ? c.move(x-@x,y-@y) : c.move(x-@x,y-@y,a-@a)}
    @x,@y=x,y
    
    @c.each{|c| dist=distance(@x,@y,c.x,c.y) ; rot=angle(@x,@y,c.x,c.y)
      c.set(@x+offset_x(rot+(a-@a),dist),@y+offset_y(rot+(a-@a),dist))
    }
    @a=a
  end
  
  def move(x=0,y=0,a=0)
    @c.each{|c| c.class==Collision_Ball ? c.move(x,y) : c.move(x,y,a)}
    @x+=x
    @y+=y
    @a-=a
    
    @c.each{|c| dist=distance(@x,@y,c.x,c.y) ; rot=angle(@x,@y,c.x,c.y)
      c.set(@x+offset_x(rot+a,dist),@y+offset_y(rot+a,dist))}
  end
end

class Camera < Entity
  attr_reader :done
  def initialize(x,y)
    @x,@y=x,y
    @offx=@offy=@shake_x=@shake_y=0
    init
  end
  
  def update
    x0,y0=@x,@y
    
    if @follow
      x=@follow.x+@offx ; y=@follow.y+@offy
      if @smooth
        if distance(@x,@y,x,y)>@smooth
          dir=angle(@x,@y,x,y)
          @x+=offset_x(dir,@smooth)
          @y+=offset_y(dir,@smooth)
        else
          @x=x ; @y=y
        end
      else
        @x=x ; @y=y
      end
    end
    
    if @move
      x=@move[0]+@offx ; y=@move[1]+@offy
      if distance(@x,@y,x,y)>@move[2]
        dir=angle(@x,@y,x,y)
        @x+=offset_x(dir,@move[2])
        @y+=offset_y(dir,@move[2])
      else
        @x=x ; @y=y
      end
    end
    
    if @scroll
      @x+=@scroll[0]
      @y+=@scroll[1]
    end
    
    if @boundary
      @x=[[@boundary[0],@x].max,@boundary[1]].min
      @y=[[@boundary[2],@y].max,@boundary[3]].min
    end
    
		if @shake
      @shake[0]+=1
      if @shake[0]==@shake[2]
        @shake[3]-=1
        @shake[0]=0
        
        @shake_x=-@shake[1]+rand(@shake[1]*2+1)
        @shake_y=-@shake[1]+rand(@shake[1]*2+1)
      end
      
			if @shake[3]==0
        @shake=nil
        @shake_x=@shake_y=0
      end
		end
    
    @done=true if @x==x0 and @y==y0
  end
  
  def draw
    if @shake and @boundary and $state.camera==self
      x=@x+@shake_x ; y=@y+@shake_y
      w=$screen.width/2 ; h=$screen.height/2
			$screen.draw_quad(x-w,y-h,c=0xff000000,x+w,y-h,c,x+w,@boundary[2]-h,c,x-w,@boundary[2]-h,c,$state.shake_z) if y<@boundary[2]
			$screen.draw_quad(@boundary[1]+w,y-h,c=0xff000000,x+w,y-h,c,x+w,y+h,c,@boundary[1]+w,y+h,c,$state.shake_z) if x>@boundary[1]
			$screen.draw_quad(x-w,@boundary[3]+h,c=0xff000000,x+w,@boundary[3]+h,c,x+w,y+h,c,x-w,y+h,c,$state.shake_z) if y>@boundary[3]
			$screen.draw_quad(x-w,y-h,c=0xff000000,@boundary[0]-w,y-h,c,@boundary[0]-w,y+h,c,x-w,y+h,c,$state.shake_z) if x<@boundary[0]
    end
  end
  
  def follow(entity,smooth=false)
    reset
    @follow=entity
    @smooth=smooth
  end
  
  def move(x,y,speed)
    reset
    @move=[x,y,speed]
  end
  
  def scroll(x,y)
    reset
    @scroll=x,y
  end
  
  def boundary(x1,y1,x2,y2)
    @boundary=[x1+$screen.width/2,x2-$screen.width/2,y1+$screen.height/2,y2-$screen.height/2]
  end
  
  def offset(x,y)
    @offx=x if x
    @offy=y if y
  end
  
  def set(x,y)
    @x=x+@offx
    @y=y+@offy
  end
  
  def pos_x
    @x-$screen.width/2+@shake_x
  end
  
  def pos_y
    @y-$screen.height/2+@shake_y
  end
  
  def shake(max,time,num)
    @shake=[time-1,max,time,num+1]
  end
  
  def reset
    @follow=@move=@scroll=@done=nil
  end
  
  def shader(shader)
    @shader=shader
  end
  
  def shader?
    @shader
  end
  
  def shaking? ; @shake end
end

class Sequence < Entity
  def initialize(sequence)
    @sequence=sequence
    init
  end
  
  def update
    @action||=@sequence[0]
    case @action[:type]
      when :wait
      next_action if (@action[:time]-=1)==0
      
      when :camera_move
      if !@setup
        $state.camera.move(@action[:target][0],@action[:target][1],@action[:target][2])
        @setup=true
      elsif $state.camera.done or @action[:skip]
        next_action
      end
      
      when :camera_follow
      if !@setup
        $state.camera.follow(@action[:target],@action[:smooth])
        @setup=true
      elsif $state.camera.done or @action[:skip]
        next_action
      end
      
      when :flash
      if !@setup
        $state.flash(*@action[:values])
        @setup=true
      elsif !$state.flashing? or @action[:skip]
        next_action
      end
      
      when :shake
      if !@setup
        $state.shake(*@action[:values])
        @setup=true
      elsif !$state.camera.shaking? or @action[:skip]
        next_action
      end
      
      when :trail
      if !@setup
        @setup=Trail.new(*@action[:values])
      elsif @setup.removed or @action[:skip]
        next_action
      end
      
      when :trace
      if !@setup
        @setup=Trace.new(*@action[:values])
      elsif @setup.removed or @action[:skip]
        next_action
      end
      
      when :particle
      if !@setup
        @setup=Particle.new(*@action[:values])
      elsif @setup.removed or @action[:skip]
        next_action
      end
      
      when :sample
      if !@setup
        @setup=Snd[@action[:name]].play
      elsif !@setup.playing? or @action[:skip]
        next_action
      end
      
      when :entity
      @setup=Kernel.const_get(@action[:class]).new(*@action[:values])
      next_action
      
      when :stop
      $state.player.stop=@action[:value] #stop is a built-in variable to prevent entity from updating
      next_action
      
      when :kill_tnt
      @action[:tnt].remove
      next_action
    end
  end
  
  def next_action
    @setup=nil
    @action=nil
    @sequence.shift
    remove if @sequence.empty?
  end
end

class Light < Entity
  attr_accessor :radius,:color,:luminance
  def initialize(x,y,radius,color=0xffffffff,luminance=1)
    @x,@y,@radius,@color,@luminance=x,y,radius,color,luminance
    init
  end
  
  def update
    $state.lights << self
  end
end