class Map
  attr_reader :width, :height, :gems
  
  def initialize(name)
    @tiles=[]
    #this super-complicated method makes a map from image, by checking each pixel
    level=Ashton::Texture.new(Img[name].width, Img[name].height) #make a texture with size of image
    level.render{Img[name].draw(0,Img[name].height,0,1,-1)} #draw image on texture (upside down, because of bug in library)
    level.width.times{ |x| level.height.times{ |y| # iterate each pixel
      case level[x,y]
        when Color::BLACK #black pixels are tiles
        Tile.new(x*50,y*50,1)
        
        @tiles[x]||=[]
        @tiles[x][y]=true
        
        when Color::GREEN #green pixels are grass
        Tile.new(x*50,y*50,0)
        
        @tiles[x]||=[]
        @tiles[x][y]=true
        
        when Color::BLUE #blue pixels are gems
        CollectibleGem.new(x*50+25,y*50+25)
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
    Tls['CptnSapphire Tileset',60][@tile].draw(@x-5,@y-5,1) #notice the Tls method, which returns the same array as load_tiles ; 60 is width and ommiting height makes square tiles
  end
end