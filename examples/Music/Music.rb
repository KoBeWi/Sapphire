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
  def initialize(fullscreen=false)
    super(640, 480, fullscreen) #set resolution and fullscreen mode
    self.caption="Title" #set window caption
    $time=0
    Keypress.Define :left=>KbLeft, :right=>KbRight, :jump=>KbSpace #define input to use with Keypress[] method
  end

  def update
    GUI::System.Update if $enable_gui
    $state.update
    $time+=1
    
    Keypress.Clean
    
    Msc[$premusic[1]].play(true) if $premusic and !$premusic[0].playing? and !$premusic[0].paused?
  end

  def draw
    $state.draw
    GUI::System.Draw if $enable_gui
  end
  
  def button_down(id)
    Keypress.Push(id)
    $state.button_down(id) if $state.respond_to?(:button_down)
  end
  
  def button_up(id)
    Keypress.Remove(id)
    $state.button_up(id) if $state.respond_to?(:button_up)
  end
end

$screen=Main.new
GUI::System.Init
$state=Game.new
$screen.show
