class Game
	attr_accessor :entities,:scx,:scy
  def initialize
		$game=self
		reset
    @scx=@scy=0
    @removed=[]
    
    @speed=20
    @fx="Fade1"
  end
  
  def update
		@entities[0].each {|ent| ent.update if ent.respond_to?(:update) and !ent.stop and !ent.removed}
    
    @removed.each{|ent| @entities.each{|grp| grp.delete(ent)}}
    @removed.clear
    
    $screen.caption="Fade example - effect #{@fx} ; speed #{@speed} ; mode #{$screen.mode? ? "Solid" : "Smooth"}"
  end
  
  def draw
    Img['Garden'].draw(0,0,0)
    #Some controls
    Fnt[FONT,20].draw("The Controls:",0,0,0, 1,1,0xff000000)
    Fnt[FONT,20].draw("Space - Fade out",0,20,0, 1,1,0xff000000)
    Fnt[FONT,20].draw("Enter - Fade in",0,40,0, 1,1,0xff000000)
    Fnt[FONT,20].draw("1 - Solid mode",0,60,0, 1,1,0xff000000)
    Fnt[FONT,20].draw("2 - Smooth mode",0,80,0, 1,1,0xff000000)
    Fnt[FONT,20].draw("3-5 - Set effect",0,100,0, 1,1,0xff000000)
    Fnt[FONT,20].draw("6,7 - Decrease/Increase speed",0,120,0, 1,1,0xff000000)
    
    $screen.translate(-@scx,-@scy) do
      @entities[0].each {|ent| ent.draw if ent.respond_to?(:draw) and !ent.invisible and !ent.removed}
    end
  end
  
  def button_down(id)
    $screen.fade_out(@fx,@speed) if id==KbSpace #fade out ; @fx is name of fade effect from 'data/fades' ; when screen is faded out, it no longer calls draw (unless you unfade it or fade in)
    $screen.fade_in(@fx,@speed) if id==KbReturn #fade in
    $screen.fade_mode(true) if id==Kb1 #make a solid mode
    $screen.fade_mode(false) if id==Kb2 #smooth
    @fx="Fade1" if id==Kb3
    @fx="Fade2" if id==Kb4
    @fx="Fade3" if id==Kb5
    @speed-=1 if id==Kb6
    @speed+=1 if id==Kb7
  end

	def solid?(x,y,down=true)
	end

	def reset
		@entities=[[]] ; 1.times{@entities<<[]} #change to number of defined groups
	end

	def missing?(obj)
		!@entities[0].include?(obj) or obj.removed
	end
  
  def find(&search)
    $game.entities[0].find search
  end
  
  def find2(group,&search)
    $game.entities[group].find search
  end
  
  def remove(ent)
    @removed << ent
  end
end