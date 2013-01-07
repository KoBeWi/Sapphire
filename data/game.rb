class Game
	attr_accessor :entities,:scx,:scy
  def initialize
		$game=self
		reset
    @scx=@scy=0
  end
  
  def update
		@entities[0].each {|ent| ent.update if ent.respond_to?(:update) and !ent.stop}
  end
  
  def draw
    $screen.translate(-@scx,-@scy) do
      @entities[0].each {|ent| ent.draw if ent.respond_to?(:draw) and !ent.invisible}
    end
  end
  
  def button_down(id)
  end

	def solid?(x,y,down=true)
	end

	def reset
		@entities=[[]] ; 1.times{@entities<<[]}
	end

	def missing(obj)
		!@entities[0].include?(obj)
	end
end