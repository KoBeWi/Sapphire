require 'gosu'
include Gosu
#remove some of these if you don't use EXE don't want/can't use them
require 'texplay'
require 'ashton'
require 'gl'
require 'glu'
include Gl
include Glu

require_relative 'data/scripts/specjal.rb'
require_relative 'data/scripts/gui.rb' #remove this if you don't use TexPlay
require_relative 'data/scripts/utility&fx.rb'
require_relative 'data/scripts/game.rb'
require_relative 'data/scripts/objects.rb'
#here come additional scripts (like above)

FONT=default_font_name #default font, remove if you won't use it

class Main < Window
  attr_reader :faded,:fade
  def initialize(fullscreen=false)
    super(640, 480, fullscreen) #set resolution and fullscreen mode
    self.caption="Title" #set caption
    $time=0
    $keys={:left=>KbLeft, :right=>KbRight, :jump=>KbSpace} #define input to use with Keypress[] method
    $pressing=[[],[],[]]
    
    @fader=Ashton::Shader.new(fragment: 'data/fader.frag')
    @solid=false
  end

  def update
    GUI::System.Update if $enable_gui
    $game.update
    $time+=1
    
    $pressing[1].each{|key| $pressing[0] << key}
    $pressing[1].clear
    
    Msc[$premusic[1]].play(true) if $premusic and !$premusic[0].playing? and !$premusic[0].paused?
  end

  def draw
    return if @faded
    $game.draw
    GUI::System.Draw if $enable_gui
    if @fade
      flush
      @fade[3]-=(@fade[2] ? @fade[1] : -@fade[1])
      @fader.Value=@fade[3]*0.001
      Img["fades/#{@fade[0]}"].draw(0,0,0,:shader=>@fader)
    end
  end
  
  def button_down(id)
    $pressing[1] << id
    $game.button_down(id) if $game.respond_to?(:button_down)
  end
  
  def button_up(id)
    $pressing[0].delete(id)
    $game.button_up(id) if $game.respond_to?(:button_up)
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
  
  def mode?;@solid;end
end

$screen=Main.new
GUI::System.Init
$game=Game.new
$screen.show
