class Load #state for loading things, the one that happens before everything ; change it to your needs
  def initialize
    bind_keys :left=>KbLeft, :right=>KbRight, :jump=>KbSpace #define input to use with Key methods ; calling it anytime will override existing ones
    
    dirs=['gfx','sfx','music']
    @gfx=[]
    @sfx=[]
    @mfx=[]
    
    while !dirs.empty?
      (Dir.entries('data/'+dirs.first)-['.','..']).each{|file|
      if Dir.exists?('data/'+dirs.first+'/'+file)
        dirs << (dirs.first+'/'+file)
      else
        case dirs.first.split('/').first
          when 'gfx'
          @gfx << (dirs.first.gsub(/gfx\//, '')+'/'+file)
          when 'sfx'
          @sfx << (dirs.first.gsub(/sfx\//, '')+'/'+file)
          when 'music'
          @mfx << (dirs.first.gsub(/music\//, '')+'/'+file)
        end
      end}
      dirs.shift
    end
    #remove these lines if using smooth loading
    @gfx.each{|file| img(file.chomp('.png'))}
    @sfx.each{|file| snd(file.chomp('.ogg'))}
    @mfx.each{|file| msc(file.chomp('.ogg'))}
  end
  
  def update
    dt=milliseconds
    while milliseconds-dt<16
      if !@gfx.empty?
        img(@gfx.pop.chomp('.png'))
      elsif !@sfx.empty?
        snd(@sfx.pop.chomp('.ogg'))
      elsif !@mfx.empty?
        msc(@mfx.pop.chomp('.ogg'))
      else
        InGame.new
        break
      end
    end
  end
  
  def draw
    $sapphire_system.light_shader ||= Ashton::Shader.new(fragment: 'data/core/light.frag') if USE_ASHTON
    return InGame.new #remove this line to make a smooth loading
    #you can use number of @gfx, @sfx and @mfx elements to draw loading bar
  end
end

class InGame < State
  FLASH_Z = 5 #Z order of flash effect
  SHAKE_Z = 5 #Z order of shake effect's boundary
  DARK_Z = 5 #Z order of shadows
  
  def groups
    [ #define entity groups
      [:solid],
      [:character, :enemy],
      [:enemy],
      [:bullet]
    ]
  end
  
  def setup
    #do some setup
  end
  
  def pre
    #takes place before entities' update
  end
  
  def post
    #takes place after entities' update
  end
  
  def back
    #do some background drawing or anything
  end
  
  def front
    #place for drawing HUD, will overlap everything on screen
  end
end