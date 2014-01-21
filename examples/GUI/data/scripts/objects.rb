class Shape < Entity
  attr_accessor :type,:scale,:red
  def initialize
    @x=@y=@type=0
    @scale=10
    init
  end

  def draw
    Tls['Shapes',32][@type].draw_rot(@x,@y,1,0,0.5,0.5,@scale*0.1,@scale*0.1,(@red ? 0xffff0000 : 0xffffffff))
  end
end