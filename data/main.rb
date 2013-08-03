require 'gosu'
include Gosu
#remove some of these if you don't use EXE and don't want/can't use them
require 'texplay'
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
  def initialize(fullscreen=false)
    super(640, 480, fullscreen) #set resolution and fullscreen mode
    self.caption="Title" #set caption
    $time=0
    $keys={:left=>KbLeft, :right=>KbRight, :jump=>KbSpace} #define input to use with Keypress[] method
  end

  def update
    GUI::System.Update if $enable_gui
    $game.update
    $time+=1
    
    Keypress.Clean
    
    Msc[$premusic[1]].play(true) if $premusic and !$premusic[0].playing? and !$premusic[0].paused?
  end

  def draw
    $game.draw
    GUI::System.Draw if $enable_gui
  end
  
  def button_down(id)
    Keypress.Push(id)
    $game.button_down(id) if $game.respond_to?(:button_down)
  end
  
  def button_up(id)
    Keypress.Remove(id)
    $game.button_up(id) if $game.respond_to?(:button_up)
  end
end

$screen=Main.new
GUI::System.Init
$game=Game.new
$screen.show