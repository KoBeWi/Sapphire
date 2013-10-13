

class Projectile < Entity
  Z=2
  def initialize(x,y,type,img,args={})
    @x,@y,@type,@img,@args=x,y,type,img,args
    if @args[:animation]
      @animation=@args[:animation]+[0,0] #frames, time
    end
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
        x=@args[:follow][0].x+@args[:follow][1]
        y=@args[:follow][0].y+@args[:follow][2]
        angle=angle(@x+(@args[:follow][3] ? @args[:follow][3] : 0),@y+(@args[:follow][4] ? @args[:follow][4] : 0),x,y)
        acc=(@args[:accuracy] ? @args[:accuracy] : 1)
        diff=angle_diff(angle,@args[:dir])
        @args[:dir]+=acc if diff.round>acc
        @args[:dir]-=acc if diff.round<acc
        @args[:follow]=nil if @args[:limit] and (@args[:limit]-=1)==0
        @args[:angle]=@args[:dir]+@args[:pointing] if @args[:pointing]
      end
      
      when :arrow
      @x+=@args[:vx]
      @y+=@args[:vy]
      @args[:vy]+=(@args[:gravity] ? @args[:gravity] : 1)
      @args[:angle]=angle(0,0,@args[:vx],@args[:vy])+@args[:pointing] if @args[:pointing]
    end
    
    #good place for interactions here
  end
  
  def draw
    if @animation
      @animation[2]+=1
      if @animation[2]==@animation[1]
        @animation[3]+=1
        @animation[3]=0 if @animation[3]==@animation[0]
        if @args[:sequence]
          @img[3]=@args[:sequence][@animation[3]]
        else
          @img[3]=@animation[3]
        end
        if @type==:trail
          if @args[:repeat] and @args[:repeat]>0
            @args[:repeat]-=1
          else
            remove
          end
        end
      end
    end
    
    @args[:angle]||=0 if @args[:rotate]
    @args[:angle]+=@args[:rotate] if @args[:rotate]
    img=(@img.class == Array ? Tls[@img[0], @img[1], @img[2]][@img[3]] : Img[@img])
    size=[img.whidth,img.height] #you can change it
    if @args[:angle]
      img.draw_rot(@x+size[0]/2,@y+size[1]/2,@args[:z] ? @args[:z] : Z,@args[:angle],0.5,0.5,@args[:scalex] ? @args[:scalex] : 1,@args[:scaley] ? @args[:scaley] : 1,@args[:color] ? @args[:color] : 0xffffffff)
    else
      img.draw(@x,@y,@args[:z] ? @args[:z] : Z,@args[:scalex] ? @args[:scalex] : 1,@args[:scaley] ? @args[:scaley] : 1,@args[:color] ? @args[:color] : 0xffffffff)
    end
  end
end