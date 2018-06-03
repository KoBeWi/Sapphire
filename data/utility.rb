class Timer < Entity
  attr_reader :finished,:time
  def initialize(time)
    @time=time
    init
  end

  def update
    if (@time-=1)==0
      @finished=true
      remove
    end
  end

  def image(h=true,m=true,s=true,hs=true)
    txt=[]
    txt << "#{'0' if (t=(@time/216000%60).to_i)<10}#{t}" if h
    txt << "#{'0' if (t=(@time/3600%60).to_i)<10}#{t}" if m
    txt << "#{'0' if (t=(@time/60%60).to_i)<10}#{t}" if s
    txt << "#{'0' if (@time/0.6)%100<10}#{((@time/0.6)%100).to_i}" if hs
    txt.join(':')
  end
end

class Mover < Entity
  attr_reader :entities
  def initialize(entities,xspeed,yspeed)
    @entities,@xspeed,@yspeed=entities,xspeed,yspeed
    init
  end

  def update
    @entities.each{|ent| ent.x+=@xspeed ; ent.y+=@yspeed}
  end
end

class Flasher < Entity
  attr_reader :entities
  def initialize(entities,time1,time2=time1)
    @entities,@time1,@time2=entities,time1,time2=time1
    init
  end

  def update
    @delay||=Timer.new(@time ? @time2 : @time1)
    if @delay.finished
      @entities.each{|ent| ent.invisible=!ent.invisible}
      @delay=nil
    end
  end
  
  def remove
    init
    @entities.each{|ent| ent.invisible=nil}
    @delay=@time=nil
  end
end

class Delayer < Entity
  attr_reader :entities
  def initialize(entities,time)
    @entities,@time=entities,time
    init
  end

  def update
    @entities.each{|ent| ent.stop=true if ent != self} if !@delay
    @delay||=Timer.new(@time)
    if @delay.finished
      @entities.each{|ent| ent.stop=false}
      @delay=nil
    end
  end
  
  def remove
    init
    @entities.each{|ent| ent.stop=nil}
    @delay=nil
  end
end

class Combo < Entity
  attr_reader :trigger
  def initialize(timeout,*sequence)
    @timeout,@sequence=timeout,sequence
    @sequence.collect!{|key| key.class==Symbol ? key_bound(key) : key}
    @combo=[]
    @time=0
    init
  end
  
  def update
    @time+=1
    if key_press
      @combo << key_press
      @time=0
    end
    @combo.clear if @time==@timeout
    
    if @trigger
      @trigger=nil
      @combo.clear
    end
    @trigger=true if @combo.reverse.take(@sequence.length)==@sequence.reverse
  end
end

class Sequence < Entity
  def initialize(sequence)
    @sequence=sequence
    init
  end
  
  def update
    @action||=@sequence[0]
    case @action[:type]
      when :wait
      next_action if (@action[:time]-=1)==0
      
      when :camera_move
      if !@setup
        $state.camera.move(@action[:target][0],@action[:target][1],@action[:target][2])
        @setup=true
      elsif $state.camera.done or @action[:skip]
        next_action
      end
      
      when :camera_follow
      if !@setup
        $state.camera.follow(@action[:target],@action[:smooth])
        @setup=true
      elsif $state.camera.done or @action[:skip]
        next_action
      end
      
      when :flash
      if !@setup
        $state.flash(*@action[:values])
        @setup=true
      elsif !$state.flashing? or @action[:skip]
        next_action
      end
      
      when :shake
      if !@setup
        $state.shake(*@action[:values])
        @setup=true
      elsif !$state.camera.shaking? or @action[:skip]
        next_action
      end
      
      when :trail
      if !@setup
        @setup=Trail.new(*@action[:values])
      elsif @setup.removed or @action[:skip]
        next_action
      end
      
      when :trace
      if !@setup
        @setup=Trace.new(*@action[:values])
      elsif @setup.removed or @action[:skip]
        next_action
      end
      
      when :particle
      if !@setup
        @setup=Particle.new(*@action[:values])
      elsif @setup.removed or @action[:skip]
        next_action
      end
      
      when :sample
      if !@setup
        @setup=Snd[@action[:name]].play
      elsif !@setup.playing? or @action[:skip]
        next_action
      end
      
      when :entity
      Kernel.const_get(@action[:class]).new(*@action[:values])
      next_action
      
      when :fade_in
      if !@setup
        $screen.fade_in(@action[:effect],@action[:speed],@action[:mode])
        @setup=true
      elsif !$screen.fade
        next_action
      end
      
      when :fade_out
      if !@setup
        $screen.fade_out(@action[:effect],@action[:speed],@action[:mode])
        @setup=true
      elsif !$screen.fade
        next_action
      end
    end
  end
  
  def next_action
    @setup=nil
    @action=nil
    @sequence.shift
    remove if @sequence.empty?
  end
end