#POWERDED BY SAPPHIRE V.1.8

require 'gosu'
include Gosu
#remove some of these if you don't use EXE and don't want/can't use them
require 'ashton'
# require 'texplay' #uncomment if needed ; required for this unused GUI feature (check GUI.rb for more details)
require 'gl'
require 'glu'
include Gl
include Glu

require_relative 'data/scripts/specjal.rb' #require specjal.rb first, because it's so important
donotload=['specjal.rb']
scripts=Dir.entries('data/scripts')-(['.','..']+donotload)
scripts.each{|scr| require_relative 'data/scripts/'+scr}

FONT=default_font_name #default font, remove if you won't use it

class Main < Window
  attr_reader :faded,:fade
  def initialize(fullscreen=false)
    super(640, 480, fullscreen) #set resolution and fullscreen mode
    self.caption="Pressing" #set window caption
    $time=0
    Keypress.Define :left=>KbLeft, :right=>KbRight, :up=>KbUp, :down=>KbDown, :a=>KbLeftControl, :b=>KbLeftShift #define input to use with Keypress[] method
    
    @fader=Ashton::Shader.new(fragment: 'data/core/fader.frag')
    @solid=false
  end

  def update
    GUI::System.Update if $enable_gui
    $state.update
    $time+=1
    
    Keypress.Clean
    
    Msc[$premusic[1]].play(true) if $premusic and !$premusic[0].playing? and !$premusic[0].paused?
  end

  def draw
    return if @faded
    $state.draw
    GUI::System.Draw if $enable_gui
    
    if @fade
      flush
      @fade[3]-=(@fade[2] ? @fade[1] : -@fade[1])
      @fader.Value=@fade[3]*0.001
      Img["fades/#{@fade[0]}"].draw(0,0,0,:shader=>@fader)
    end
  end
  
  def button_down(id)
    Keypress.Push(id)
    $state.button_down(id) if $state.respond_to?(:button_down)
  end
  
  def button_up(id)
    Keypress.Remove(id)
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
GUI::System.Init
$state=Game.new
$screen.show
