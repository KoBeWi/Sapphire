class Game
	attr_accessor :entities,:scx,:scy
  def initialize
		$state=self
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
  
  def find(group=0)
    @entities[group].find{|ent| yield(ent)}
  end
  
  def remove(ent)
    @removed << ent
  end
end