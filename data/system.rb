class Collision_Manager #class for manager
  def initialize
    @window = $screen #store the window into variable
    @space = CP::Space.new #make a space for Chipmunk
    
    @colliders = [] #array for colliders
    
    @space.add_collision_func(:entity, :entity) do |collider1, collider2| #function for colliding
      collider1.owner.add_collision(collider2.owner) #when 2 objects collide, they add the second object to their collision array
      collider2.owner.add_collision(collider1.owner)
    end
  end
  
  def update
    @colliders.each{|collider| collider.clear_collisions} #each collider resets it's collisions
    @space.step(@window.update_interval) #Chipmunk space is checking for collisions, using window's update_interval as delta-time
  end
  
  def add_collider(collider)
    @colliders << collider #pushes collider to the array, so it's easily accessed by manager
    
    if collider.shape.class == Shape_Group #special case if it's Group
      collider.shape.shapes.each{|shape| #iterate through all of Group's shapes
      shape.collision_type = :entity #set collision type, each collider uses the same one
      shape.sensor = true #make shape a sensor, so it won't generate forces
      shape.owner = collider #it's a custom variable for easier accessing the Collider object from shape
      @space.add_shape(shape)} #add shape to the space
    else
      collider.shape.collision_type = :entity #pretty the same as above, but for single shape
      collider.shape.sensor = true
      collider.shape.owner = collider
      @space.add_shape(collider.shape)
    end
    
    @space.add_body(collider.shape.body) #add body to the space
  end
  
  def remove_collider(collider) #this one is the same as add_collider, but does the opposite
    @colliders.delete(collider)
    
    if collider.shape.class == Shape_Group #again, special case
      collider.shape.shapes.each{|shape| #every shape need to be removed
      @space.remove_shape(shape)}
    else
      @space.remove_shape(collider.shape) #shape is only removed, unlike #add, no values are changed (because why)
    end
    
    @space.remove_shape_body(collider.shape.body) #and remove the body
  end
end

class Collider #super-class for colliders
  attr_reader :shape, :collisions #acces for shape and collisions of the collider
  def collides?(collider)
    @collisions.include?(collider) #this method checks if given object is currently colliding with the collider (in that case, it's in the array)
  end
  
  def add_collision(collider)
    @collisions << collider #this method pushes the collider colliding with this collider
  end
  
  def clear_collisions
    @collisions.clear #clears collisions, it's used each frame and the array is filled each frame, still no lags
  end
  
  def remove
    @manager.remove_collider(self) #remove the collider from the existence
  end
end

class Collision_Box < Collider #class for boxes, it inherits from Collider (like all colliders, because they are colliders)
  def initialize(x, y, w, h, angle = 0)
    @manager = $state.manager #assign the manager
    body = CP::Body.new(1, 1)  #make a new body, mass and the second variable doesn't matter
    #this is a super-complicated (or not) method to calculate the vertices of the box
    d = distance(0, 0, w, h) / 2 #half of box's diagonal
    a = angle(0, 0, w, h).gosu_to_radians #angle between diagonal and box's lines
    a1 = body.a #it's always 0
    
    vectors = [CP::Vec2.new(Math.sin(a1 - a) * d, Math.cos(a1 - a) * d), #here we are calculating vertices of the box using some sines and cosines etc.
    CP::Vec2.new(Math.sin(a1 + a) * d, Math.cos(a1 + a) * d),
    CP::Vec2.new(Math.sin(a1 + Math::PI - a) * d, Math.cos(a1 + Math::PI - a) * d),
    CP::Vec2.new(Math.sin(a1 + Math::PI + a) * d, Math.cos(a1 + Math::PI + a) * d)
    ] #clossing brace, yes, it was an array
    
    @shape = CP::Shape::Poly.new(body, vectors, CP::Vec2.new(0,0)) #make a new shape using the body, array of veretices and zero-vector of offset (no one needs it. no one)
    set(x, y, angle) #move the collider to it's desired start position, because initially it's made at 0,0
    
    @collisions = [] #making an array for collisions
    @manager.add_collider(self) #make the manager add the box to space
  end
  
  def x=(value)
    @shape.body.p = CP::Vec2.new(value, @shape.body.p.y) #change body horizontal position to the given one, it will move also the shape
  end
  
  def y=(value)
    @shape.body.p = CP::Vec2.new(@shape.body.p.x, value) #change body vertical position to the given one, it will move also the shape
  end
  
  def a=(value)
    @shape.body.a = value.gosu_to_radians #change body angle to the given one, it will rotate also the shape
  end
  
  def set(x, y, angle = nil) #all-in-one method for moving the collider
    @shape.body.p = CP::Vec2.new(x, y)
    @shape.body.a = angle.gosu_to_radians if angle #change the angle only if it was given
  end
end

class Collision_Ball < Collider #class for balls (circles)
  def initialize(x, y, r)
    @manager = $state.manager #everything the same as for box
    body = CP::Body.new(1, 1)
    
    @shape = CP::Shape::Circle.new(body, r, CP::Vec2.new(0,0)) #here, shape is made withous super-calculating, given only body, range and useless offset
    set(x, y)
    
    @collisions = []
    @manager.add_collider(self)
  end
  
  def x=(value)
    @shape.body.p = CP::Vec2.new(value, @shape.body.p.y)
  end
  
  def y=(value)
    @shape.body.p = CP::Vec2.new(@shape.body.p.x, value)
  end
  
  def set(x, y)
    @shape.body.p = CP::Vec2.new(x, y) #note that there's no angle this time, so don't try to pass it
  end
end

class Collision_Group < Collider #class for complex shapes
  def initialize(x, y, angle, *colliders) #notice the * before collider, it converts arguments into array
    @manager = @manager = $state.manager #a bit the same
    body = CP::Body.new(1, 1)
    @shape = Shape_Group.new(body) #this time, shape is a group of shapes, because it's Group
    
    colliders.each{|col| #iterate through each given colliders to make complex shape, each collider is an array that goes like this [:type, x, y, w/r, h, a], where x and y are position relatively to the center of group and h and a are for box only
    if col[0] == :box #if collider is a box
      d = distance(0, 0, col[3], col[4]) / 2 #again this method
      a = angle(0, 0, col[3], col[4]).gosu_to_radians
      a1 = col[5] ? col[5] : body.a #set angle to the given one if given
      
      vectors = [CP::Vec2.new(Math.sin(a1 - a) * d, Math.cos(a1 - a) * d),
      CP::Vec2.new(Math.sin(a1 + a) * d, Math.cos(a1 + a) * d),
      CP::Vec2.new(Math.sin(a1 + Math::PI - a) * d, Math.cos(a1 + Math::PI - a) * d),
      CP::Vec2.new(Math.sin(a1 + Math::PI + a) * d, Math.cos(a1 + Math::PI + a) * d)
      ]
      
      @shape.shapes << CP::Shape::Poly.new(body, vectors.each{|vec| vec.x -= col[2] ; vec.y += col[1]}, CP::Vec2.new(0,0)) #add shape to the shapes of @shape, so it's later managed by Collision_Manager like one
    else
      @shape.shapes << CP::Shape::Circle.new(body, col[3], CP::Vec2.new(-col[2], col[1])) #same as above
    end}
    
    set(x, y, angle) #each of the shape will move along with the whole group, even while rotating, so the big shape stays consistent
    
    @collisions = []
    @manager.add_collider(self)
  end
  #below methods don't change
  def x=(value)
    @shape.body.p = CP::Vec2.new(value, @body.p.y)
  end
  
  def y=(value)
    @shape.body.p = CP::Vec2.new(@body.p.x, value)
  end
  
  def a=(value)
    @shape.body.a = value.gosu_to_radians
  end
  
  def set(x, y, angle = nil)
    @shape.body.p = CP::Vec2.new(x, y)
    @shape.body.a = angle.gosu_to_radians if angle
  end
end

class Shape_Group #group of shapes with values accessed by manager etc.
  attr_reader :body, :shapes
  def initialize(body)
    @body = body
    @shapes = []
  end
end

module CP #it add small extension to the Chipmunk, such a hack, wow
  module Shape
    class Poly
      attr_accessor :owner #owner is needed to easily acces the Collider with this shape, otherwise there would be lags, believe me
    end
    
    class Circle
      attr_accessor :owner
    end
  end
end

class Camera < Entity
  def initialize(x,y)
    @x,@y=x,y
    @offx=@offy=@shake_x=@shake_y=0
    init
  end
  
  def update
    if @follow
      x=@follow.x+@offx ; y=@follow.y+@offy
      if @smooth
        if distance(@x,@y,x,y)>@smooth
          dir=angle(@x,@y,x,y)
          @x+=offset_x(dir,@smooth)
          @y+=offset_y(dir,@smooth)
        else
          @x=x ; @y=y
          @done=true
        end
      else
        @x=x ; @y=y
        @done=true
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
        @done=true
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
  
  def scroll(vx,vy)
    @scroll=vx,vy
    
    @follow=@move=nil
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
  
  def shader(shader)
    @shader=shader
  end
  
  def shader?
    @shader
  end
  
  def shake(max,time,num)
    @shake=[time-1,max,time,num+1]
  end
end