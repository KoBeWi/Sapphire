require 'gosu'
include Gosu
require 'texplay'
require 'gl'
require 'glu'
include Gl
include Glu

scr="#{Dir.getwd}/data/scripts/"
require scr+'specjal.rb'
require scr+'gui.rb'
require scr+'utility&fx.rb'
require scr+'game.rb'
require scr+'objects.rb'
FONT=default_font_name

class Main < Window
  def initialize(fullscreen=false)
    super(640, 480, fullscreen)
    self.caption="Title"
    $count=0
    $keys={:left=>KbLeft, :right=>KbRight, :jump=>KbSpace}
    $pressing=[[],[],[]]
  end

  def update
    GUI::System.Update if $enable_gui
    $game.update
    $count+=1
    
    $pressing[0].each{|key| $pressing[2] << key if !button_down?(key)}
    $pressing[2].each{|key| $pressing[0].delete(key)}
    $pressing[2].clear
    $pressing[1].each{|key| $pressing[0] << key}
    $pressing[1].clear
    
    Msc[$premusic[1]].play(true) if $premusic and !$premusic[0].playing? and !$premusic[0].paused?
  end

  def draw
    $game.draw
    GUI::System.Draw if $enable_gui
  end
  
  def button_down(id)
    $game.button_down(id) if $game.respond_to?(:button_down)
  end
  
  def button_up(id)
    $game.button_up(id) if $game.respond_to?(:button_up)
  end
end

$screen=Main.new
GUI::System.Init
$game=Game.new
$screen.show