class Game
	attr_accessor :entities,:scx,:scy
  def initialize
		$game=self
		reset
    @scx=@scy=0
    @removed=[]
  end
  
  def update
		@entities[0].each {|ent| ent.update if ent.respond_to?(:update) and !ent.stop and !ent.removed}
    
    @removed.each{|ent| @entities.each{|grp| grp.delete(ent)}}
    @removed.clear
  end
  
  def draw
    $screen.translate(-@scx,-@scy) do
      @entities[0].each {|ent| ent.draw if ent.respond_to?(:draw) and !ent.invisible and !ent.removed}
    end
  end
  
  def button_down(id)
  end

	def solid?(x,y,down=true)
	end

	def reset
		@entities=[[]] ; 1.times{@entities<<[]} #change #.times to number of defined groups
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