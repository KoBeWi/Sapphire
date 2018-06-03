#POWERDED BY SAPPHIRE V.1.11
USE_ASHTON = true
USE_CHIPMUNK = true

begin

require 'gosu'
include Gosu
require 'ashton' if USE_ASHTON
require 'chipmunk' if USE_CHIPMUNK

require_relative 'data/core/core.rb'
scripts=Dir.entries('data/scripts')-['.','..']
scripts.each{|scr| require_relative 'data/scripts/'+scr}

class Main < Window
  attr_reader :faded,:fade
  def initialize(fullscreen=false)
    super(640, 480, fullscreen) #set resolution and fullscreen mode
    self.caption="Title" #set window caption
    $time=0
    
    @solid=false
  end

  def update
    $sapphire_system.update
    $state.update
    $time+=1
  end

  def draw
    @fader = Ashton::Shader.new(fragment: 'data/core/fader.frag') if !@fader and USE_ASHTON
    return if @faded
    $state.draw
    $sapphire_system.draw
    
    if @fade
      flush
      @fade[3]-=(@fade[2] ? @fade[1] : -@fade[1])
      @fader.Value=@fade[3]*0.001
      Img["fades/#{@fade[0]}"].draw(0,0,0,:shader=>@fader)
      if @fade[2] and @fade[3]<=0
        @fade=nil
        @faded=true
      end
    end
  end
  
  def button_down(id)
    $sapphire_system.button_down=id
    $state.button_down(id) if $state.respond_to?(:button_down)
  end
  
  def button_up(id)
    $sapphire_system.button_up=id
    $state.button_up(id) if $state.respond_to?(:button_up)
  end
  
  def fade_out(fade,speed,solid=:auto)
    @faded=nil
    @fader.Solid=(solid != :auto ? solid : @solid)
    @fade=[fade,speed,true,1000]
  end
  
  def fade_in(fade,speed,solid=:auto)
    @faded=nil
    @fader.Solid=(solid != :auto ? solid : @solid)
    @fade=[fade,speed,false,@solid ? 0 : -1000]
  end
  
  def unfade
    @faded=nil
  end
  
  def fade_mode(solid)
    @fader.Solid=@solid=solid
  end
end

$screen=Main.new
$state=Load.new
$screen.show

rescue Exception => e
f=File.new('crash log.txt','w')
f.puts e
f.puts e.backtrace
f.close
end