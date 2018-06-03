class Projectile < Entity
  Z=2
  def initialize(x,y,type,img,args={})
    @x,@y,@type,@img,@args=x,y,type,img,args
    if @args[:animation]
      @animation=@args[:animation]+[0,0] #frames, time
    end
    @size=[0,0] #initial value
    
    @time=0
    init
  end
  
  def update
    @time+=1
    case @type
      when :trail
      @x+=@args[:movex] if @args[:movex]
      @y+=@args[:movey] if @args[:movey]
      
      if !@animation
        if @args[:repeat] and @args[:repeat]>0
          @args[:repeat]-=1
        else
          remove
        end
      end
      
      when :bullet
      @x+=offset_x(@args[:dir],@args[:speed] ? @args[:speed] : 1)
      @y+=offset_y(@args[:dir],@args[:speed] ? @args[:speed] : 1)
      
      if @args[:follow] #target entity, entity offset x, entity offset y, bullet offset x, bullet offset y
        x=@args[:follow][0].x+(@args[:follow][1] ? @args[:follow][1] : 0)
        y=@args[:follow][0].y+(@args[:follow][2] ? @args[:follow][2] : 0)
        angle=angle(@x+(@args[:follow][3] ? @args[:follow][3] : 0),@y+(@args[:follow][4] ? @args[:follow][4] : 0),x,y)
        acc=(@args[:accuracy] ? @args[:accuracy] : 1)
        diff=angle_diff(angle,@args[:dir])
        @args[:dir]+=acc if diff.round<acc
        @args[:dir]-=acc if diff.round>acc
        @args[:follow]=nil if @args[:limit] && (@args[:limit]-=1)==0 or @args[:follow][0].removed
        @args[:angle]=@args[:dir]+@args[:pointing] if @args[:pointing]
      end
      
      if @args[:custom] #you can change Projectile class to your needs ; this is example
        @args[:speed]-=0.2 #decelerate
        if @args[:speed]<=0
          remove
          Projectile.new(@x-26,@y-30,:trail,['Explosion',68,76,0],:animation=>[6,4],:pierce=>true) #explode
        end
      end
      
      when :arrow
      if !@args[:vx] or !@args[:vy]
        @args[:vx]||=offset_x(@args[:dir],@args[:power])
        @args[:vy]||=offset_y(@args[:dir],@args[:power])
      end
      
      @x+=@args[:vx]
      @y+=@args[:vy]
      @args[:vy]+=(@args[:gravity] ? @args[:gravity] : 1)
      @args[:angle]=angle(0,0,@args[:vx],@args[:vy])+@args[:pointing] if @args[:pointing]
    end
    
    if !@args[:custom] and bird=$state.find(1) {|bird| distance(@x+@size[0]/2,@y+@size[1]/2,bird.x+22,bird.y+22)<@size.min} #check for collision with bird ; you can use provided collision classes, but here calculations are used ; we check in entity group 1, which is group for birds
      bird.remove #kill him!
      remove if !@args[:pierce] #remove bullet when it can't go through
      $state.kills+=1
    end
  end
  
  def draw
    if @animation
      @animation[2]+=1
      if @animation[2]==@animation[1]
        @animation[2]=0
        @animation[3]+=1
        if @animation[3]==@animation[0]
          @animation[3]=0
          
          if @type==:trail
            if @args[:repeat] and @args[:repeat]>0
              @args[:repeat]-=1
            else
              remove
            end
          end
        end
        
        if @args[:sequence]
          @img[3]=@args[:sequence][@animation[3]]
        else
          @img[3]=@animation[3]
        end
      end
    end
    
    @args[:angle]||=0 if @args[:rotate]
    @args[:angle]+=@args[:rotate] if @args[:rotate]
    img=(@img.class == Array ? Tls[@img[0], @img[1], @img[2]][@img[3]] : Img[@img])
    size=[img.width,img.height]
    @size=size #save the collision size of object
    if @args[:angle]
      img.draw_rot(@x+size[0]/2,@y+size[1]/2,@args[:z] ? @args[:z] : Z,@args[:angle],0.5,0.5,@args[:scalex] ? @args[:scalex] : 1,@args[:scaley] ? @args[:scaley] : 1,@args[:color] ? @args[:color] : 0xffffffff)
    else
      img.draw(@x,@y,@args[:z] ? @args[:z] : Z,@args[:scalex] ? @args[:scalex] : 1,@args[:scaley] ? @args[:scaley] : 1,@args[:color] ? @args[:color] : 0xffffffff)
    end
  end
end

class Boat < Entity
  attr_reader :weapon
  def initialize
    @x,@y=272,405
    @angle=@weapon=0
    init
  end
  
  def update
    @x+=8 if @x<592 and Keypress[KbRight]
    @x-=8 if @x>-48 and Keypress[KbLeft]
    
    @angle=angle(@x+48,@y,$screen.mouse_x,$screen.mouse_y)
    
    @weapon+=1 if Keypress[MsMiddle,false]
    @weapon=0 if @weapon==4
    
    if Keypress[MsLeft,false] or Keypress[MsRight] && $time%8==0
      case @weapon
        when 0
        Projectile.new(@x+40,@y-8,:bullet,['Projectiles',16,16,0],:dir=>@angle,:speed=>8)
        
        when 1
        enemies=[] #prepare array
        $state.entities[1].each{|bird| enemies << distance(@x+48,@y,bird.x+22,bird.y+22)} #push distances from boat to each bird
        bird=$state.entities[1][enemies.index(enemies.min)] #choose the closest so it will be targeted
        Trace.new(bird.x+6,bird.y+6,2,'Target',16) #indicate the choosen one
        
        Projectile.new(@x+40,@y-8,:bullet,['Projectiles',16,16,1],:dir=>@angle,:speed=>6,:follow=>[bird],:accuracy=>4,:pointing=>0)
        
        when 2
        Projectile.new(@x+40,@y-8,:arrow,['Projectiles',16,16,2],:dir=>@angle,:power=>27,:pierce=>true,:pointing=>0)
        
        when 3
        Projectile.new(@x+40,@y-8,:bullet,['Projectiles',16,16,3],:dir=>@angle,:speed=>8+rand(5),:custom=>true) #this projectile uses custom method ; see line 45
      end
    end
  end
  
  def draw
    Img['Boat'].draw(@x,@y,1)
    Img['Cannon'].draw_rot(@x+48,@y,3,@angle)
    Img['Crosshair'].draw_rot($screen.mouse_x,$screen.mouse_y,0,0)
  end
end

class Bird < Entity
  def initialize
    @x,@y=[-55,640][rand(2)],rand(220)
    @left=(@x==640)
    init(:bird)
  end
  
  def update
    @x+=(@left ? -4 : 4)
    remove if @x>660 or @x<-70
  end
  
  def draw
    Tls['Seabird',55][$time/8%4].draw(@x+(@left ? 55 : 0),@y,1,(@left ? -1 : 1))
  end
end