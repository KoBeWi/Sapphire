class Map
  attr_reader :width, :height, :gems
  
  def initialize(name)
    @tiles=[]
    
    level=Ashton::Texture.new(Img[name].width, Img[name].height)
    level.render{Img[name].draw(0,Img[name].height,0,1,-1)}
    level.width.times{ |x| level.height.times{ |y|
      case level[x,y]
        when Color::BLACK
        Tile.new(x*50,y*50,1)
        
        @tiles[x]||=[]
        @tiles[x][y]=true
        
        when Color::GREEN
        Tile.new(x*50,y*50,0)
        
        @tiles[x]||=[]
        @tiles[x][y]=true
        
        when Color::BLUE
        CollectibleGem.new(x*50+25,y*50+25)
        
        when Color::RED
        TNT.new(x*50+25,y*50+25)
        
        when Color::FUCHSIA
        Console.new(x*50+25,y*50+25)
      end}}
      
    @width=level.width*50
    @height=level.height*50
    Ashton::WindowBuffer.new.render{}
  end
  
  # Solid at a given pixel position?
  def solid?(x, y)
    return if !@tiles[x / 50]
    @tiles[x / 50][y / 50]
  end
end

class Tile < Entity
  def initialize(x,y,tile)
    @x,@y,@tile=x,y,tile
    init
  end
  
  def draw
    Tls['CptnSapphire Tileset',60][@tile].draw(@x-5,@y-5,1)
  end
end