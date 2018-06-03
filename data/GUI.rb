module GUI
  #define colors (may be Gosu::Color not hex)
  D_BCKG= 0xff404040
  L_BCKG= 0xff808080
  D_FRGND= 0xffc0c0c0
  L_FRGND= 0xffffffff
  FONT_COLOR= 0xff000000
  SPECIAL_COLOR= 0xffff0000
  SPECIAL_COLOR2= 0xff9aa9e4
  FONT= 'Courier New' #set font for GUI (monospaced is recommended since it affects GUI width)
  FONT_SIZE= 16 #size of font

  class System
    attr_accessor :x,:y,:z,:disabled,:inactive
    def System.Init
      @@GUI=[]
      @@clipboard=""
    end
  
    def System.Update
      @@GUI.each{|s| s.update if !s.disabled and !s.inactive}
      @@focus=nil if @@focus and @@focus.class != Symbol and !@@GUI.include?(@@focus)
    end
  
    def System.Draw
      $screen.flush
      @@GUI.each{|s| s.draw if !s.disabled}
      $screen.flush
      img('core/GUI/Cursor').draw($screen.mouse_x,$screen.mouse_y,8)
    end
    
    def System.Z
      @@z||=0
      @@z+=10
    end
    
    def System.Z?
      @@z
    end
    
    def System.Stick(obj)
      @@stick=obj
    end
    
    def System.Stick?
      @@stick||=nil
      @@stick!=nil
    end
    
    def System.Clear
      @@GUI.clear
    end
    
    def System.Push(obj)
      @@GUI << obj
    end
    
    def System.Clipboard
      @@clipboard
    end
    
    def System.Clipboard=(value)
      @@clipboard=value
    end
    
    def System.Focus=(element)
      @@focus=element
    end
    
    def System.Focus?(element)
      @@focus=nil unless defined? @@focus
      @@focus and @@focus != element
    end
    
    def remove
      GUI::System.Remove(self)
    end
  end
  
  def GUI::text_width(value)
    fnt(FONT,FONT_SIZE).text_width(value)
  end
  
  class Window < System
    attr_accessor :docked,:nox
    def initialize(x,y,width,height,title,*customization)
      @x,@y,@width,@height,@title=x,y,width,height+Img['core/Close'].height,title
      @texts=[] ; @separators=[] ; @objects={}
      customization.each{|custom| method(custom[0]).call(custom[1...custom.length])}
      @z=GUI::System.Z
      @objects.each_value{|obj|
        obj[0].x=@x+4+obj[1]
        obj[0].y=@y+Img['core/Close'].height+obj[2]
        obj[0].z=@z
        obj[0].disabled=@disabled}
      GUI::System.Push(self)
    end

    def update
      if key_press(MsLeft)  && !GUI::System.Stick? && $screen.mouse_x>@x && $screen.mouse_x<@x+@width && $screen.mouse_y>@y && $screen.mouse_y<@y+Img['core/Close'].height or @mouse
        GUI::System.Stick(self)
        @z=GUI::System.Z
        @mouse||=[$screen.mouse_x-@x,$screen.mouse_y-@y]
        @x=$screen.mouse_x-@mouse[0] if !@docked
        @y=$screen.mouse_y-@mouse[1] if !@docked
        if !@nox and @mouse[0]>@width-Img['core/Close'].width then @mouse=nil ; @disabled=true ; GUI::System.Stick(nil) end
        (@mouse=nil ; GUI::System.Stick(nil)) if !key_press(MsLeft)
      end
      @objects.each_value{|obj|
      obj[0].x=@x+4+obj[1]
      obj[0].y=@y+Img['core/Close'].height+obj[2]
      obj[0].z=@z
      obj[0].inactive=nil}
      
      if @z != GUI::System.Z?
        @objects.each_value{|obj|
          obj[0].inactive=true}
      end
    end

    def draw
      img=Img['core/Close']
      $screen.draw_quad(@x,@y,c=(@z==GUI::System.Z? ? D_FRGND : D_BCKG),@x+@width,@y,c,@x+@width,@y+@height,c,@x,@y+@height,c,@z)
      $screen.draw_quad(@x+4,@y+img.height,c=L_BCKG,@x+@width-4,@y+img.height,c,@x+@width-4,@y+@height-4,c,@x+4,@y+@height-4,c,@z)
      img.draw(@x+@width-img.width,@y,@z+1) if !@nox
      fnt(FONT,FONT_SIZE).draw(@title,@x+4,@y,@z+1,1,1,FONT_COLOR)
      @texts.each{|txt|
        fnt(FONT,FONT_SIZE).draw(txt[0],@x+4+txt[1],@y+16+txt[2],@z+1,1,1,FONT_COLOR)}
      @separators.each{|sep|
        $screen.draw_line(@x+sep[0]+4,@y+sep[1]+16,c=L_BCKG,@x+sep[2]+4,@y+sep[3]+16,c,@z)
        $screen.draw_line(@x+sep[0]+4,@y+sep[1]+17,c=L_BCKG,@x+sep[2]+4,@y+sep[3]+17,c,@z)
        $screen.draw_line(@x+sep[0]+5,@y+sep[1]+16,c=L_BCKG,@x+sep[2]+5,@y+sep[3]+16,c,@z)}
    end
  
    def disable(arg)
      @disabled=true
    end
  
    def dock(arg)
      @docked=true
    end
  
    def nox(arg)
      @nox=true
    end
  
    def text(sets)
      @texts << sets
    end
  
    def separator(coord)
      @separators << coord
    end
  
    def object(obj)
      @objects[obj[0]]=[obj[1],obj[1].x,obj[1].y]
    end
  
    def value(name)
      @objects[name][0].value
    end
  
    def set_value(name,val)
      @objects[name][0].value=val
    end
    
    def disabled=(value)
      @disabled=value
      @objects.each_value{|obj| obj[0].disabled=@disabled}
    end
  end

  class Button < System
    def initialize(x,y,text)
      @x,@y,@text=x,y,text
      @z=1
      GUI::System.Push(self)
    end

    def update
      @clicked=nil
      if !@clicking and key_press(MsLeft) and $screen.mouse_x.between?(@x, @x+GUI::text_width(@text)+8) and $screen.mouse_y.between?(@y, @y+24)
        @clicking=true
      elsif !key_hold(MsLeft)
        @clicked=true if @clicking and $screen.mouse_x.between?(@x, @x+GUI::text_width(@text)+8) and $screen.mouse_y.between?(@y, @y+24)
        @clicking=nil
      end
    end

    def draw
      width=GUI::text_width(@text)+8
      
      c=(@clicking ? L_BCKG : D_BCKG) #bottom-right
      $screen.draw_quad(@x,@y+FONT_SIZE+4,c,@x+width+8,@y+FONT_SIZE+4,c,@x+width+8,@y+FONT_SIZE+8,c,@x,@y+FONT_SIZE+8,c,@z+2)
      $screen.draw_quad(@x+width+4,@y,c,@x+width+8,@y,c,@x+width+8,@y+FONT_SIZE+8,c,@x+width+4,@y+FONT_SIZE+8,c,@z+2)
      
      c=(@clicking ? D_FRGND : L_FRGND) #top-left
      $screen.draw_quad(@x+4,@y,c,@x+width+6,@y,c,@x+width+6,@y+4,c,@x+4,@y+4,c,@z+2)
      $screen.draw_quad(@x,@y,c,@x+4,@y,c,@x+4,@y+FONT_SIZE+6,c,@x,@y+FONT_SIZE+6,c,@z+2)
      
      c=(@clicking ? D_BCKG : D_FRGND) #middle
      $screen.draw_quad(@x+4,@y+4,c,@x+width+6,@y+4,c,@x+width+6,@y+FONT_SIZE+6,c,@x+4,@y+FONT_SIZE+6,c,@z+2)
      $screen.draw_quad(@x+4,@y+4,c,@x+width+6,@y+4,c,@x+width+6,@y+FONT_SIZE+6,L_FRGND,@x+4,@y+FONT_SIZE+6,L_FRGND,@z+2) if @clicking
      
      fnt(FONT,FONT_SIZE).draw(@text,@x+8,@y+4,@z+2,1,1,FONT_COLOR)
    end
    
    def value
      @clicked
    end
  
    def value=(val)
      @clicked=val
    end
    
    def disabled=(value)
      @disabled=value
      @clicked=nil if @disabled
    end
  end

  class Slider < System
    attr_reader :changed
    def initialize(x,y,max,unit=1,style=0,phase=0)
      @x,@y,@max,@unit,@style,@phase=x,y,max,unit,style,phase
      @z=1
      @value=0
      GUI::System.Push(self)
    end
  
    def update
      @changed=nil
      if key_hold(MsLeft) && $screen.mouse_x.between?(@x, @x+@max*@unit) && $screen.mouse_y.between?(@y-12, @y+12) or @changing
        @changing=true
        value=@value
        @value=[[$screen.mouse_x-@x,0].max,@max*@unit].min.to_i/@unit
        @changed=true if @value != value
        @changing=nil if !key_hold(MsLeft)
      end
    end
  
    def draw
      pos=@value*@unit
      $screen.draw_quad(@x,@y-2,c=L_BCKG,@x+@max*@unit,@y-2,c,@x+@max*@unit,@y,c,@x,@y,c,@z+2)
      $screen.draw_quad(@x,@y,c=D_BCKG,@x+@max*@unit,@y,c,@x+@max*@unit,@y+4,c,@x,@y+4,c,@z+2)
      
      $screen.draw_quad(@x+pos-6,@y-12,c=L_FRGND,@x+pos+6,@y-12,c,@x+pos+6,@y+12,c,@x+pos-6,@y+12,c,@z+2)
      $screen.draw_quad(@x+pos-2,@y-8,c=D_FRGND,@x+pos+2,@y-8,c,@x+pos+2,@y+8,c,@x+pos-2,@y+8,c,@z+2)
      
      if @style==0
        $screen.draw_quad(@x-GUI::text_width(@max)-12,@y-12,c=D_BCKG,@x-8,@y-12,c,@x-8,@y+12,c,@x-GUI::text_width(@max)-12,@y+12,c,@z+2)
        $screen.draw_quad(@x-GUI::text_width(@max)-10,@y-10,c=D_FRGND,@x-10,@y-10,c,@x-10,@y+10,c,@x-GUI::text_width(@max)-10,@y+10,c,@z+2)
        fnt(FONT,FONT_SIZE).draw_rel(@value+@phase,@x-GUI::text_width(@max)-10,@y,@z+3,0,0.5,1,1,FONT_COLOR)
      elsif @style==1
        fnt(FONT,FONT_SIZE).draw_rel(@value+@phase,@x+pos,@y-10,@z+3,0.5,1,1,1,FONT_COLOR)
      elsif @style==2
        (@max+1).times{|x|
          $screen.draw_quad([@x+x*@unit-1,@x].max,@y,c=L_BCKG,[@x+x*@unit+1,@x+@max*@unit].min,@y,c,[@x+x*@unit+1,@x+@max*@unit].min,@y+8,c,[@x+x*@unit-1,@x].max,@y+8,c,@z+1)
          fnt(FONT,FONT_SIZE).draw_rel(x+@phase,@x+x*@unit,@y+10,@z+3,0.5,0,1,1,FONT_COLOR)
        }
      end
    end
    
    def value
      @value+@phase
    end
  
    def value=(val)
      @value=val
    end
  end

  class Checkbox < System
    attr_reader :changed
    def initialize(x,y,tristate=nil)
      @x,@y,@tristate=x,y,tristate
      @state=false
      @z=1
      GUI::System.Push(self)
    end

    def update
      @changed=nil
      if !@changing and key_press(MsLeft) and $screen.mouse_x.between?(@x,@x+24) and $screen.mouse_y.between?(@y,@y+24)
        @changing=true
      elsif !key_hold(MsLeft)
        if @changing and $screen.mouse_x.between?(@x,@x+24) and $screen.mouse_y.between?(@y,@y+24)
          @changed=true
          state=@state
          @state=!@state
          @state=nil if @tristate and state
          @state=false if @tristate and state==nil
        end
        @changing=nil
      end
    end

    def draw
      $screen.draw_quad(@x,@y,c=D_BCKG,@x+24,@y,c,@x+24,@y+24,c,@x,@y+24,c,@z+2)
      $screen.draw_quad(@x+2,@y+2,c=D_FRGND,@x+22,@y+2,c,@x+22,@y+22,c,@x+2,@y+22,c,@z+2)
      if @state
        $screen.draw_line(@x+6,@y+11,c=SPECIAL_COLOR,@x+10,@y+15,c,@z+3)
        $screen.draw_line(@x+10,@y+15,c,@x+17,@y+8,c,@z+3)
        $screen.draw_line(@x+6,@y+12,c=SPECIAL_COLOR,@x+10,@y+16,c,@z+3)
        $screen.draw_line(@x+10,@y+16,c,@x+17,@y+9,c,@z+3)
        $screen.draw_line(@x+6,@y+13,c=FONT_COLOR,@x+10,@y+17,c,@z+3)
        $screen.draw_line(@x+10,@y+17,c,@x+17,@y+10,c,@z+3)
      elsif @state==nil
        $screen.draw_quad(@x+4,@y+4,c=FONT_COLOR,@x+20,@y+4,c,@x+20,@y+20,c,@x+4,@y+20,c,@z+2)
        $screen.draw_quad(@x+6,@y+6,c=SPECIAL_COLOR,@x+18,@y+6,c,@x+18,@y+18,c,@x+6,@y+18,c,@z+2)
      end
    end
    
    def value
      @state
    end
  
    def value=(val)
      @state=val
    end
  end

  class Radio < System
    attr_reader :choices,:changed
    def initialize(x,y,*choices)
      @x,@y,@choices=x,y,choices
      @z=1
      @choice=0
      @width=20
      @height=@choices.length*FONT_SIZE+12
      img=tls('core/GUI/Radio',-2,-1)[0]
      
      @ys=[]
      @choices.each{|ch| w=GUI::text_width(ch)
        @width=w+20+img.width if w+img.width>@width
        @ys << ((8+(i=@choices.index(ch)*FONT_SIZE))...(8+i+img.height)).to_a
      }
      @last=[@x,@y,@choices.length]
      
      GUI::System.Push(self)
    end

    def update
      @changed=nil
      img=tls('core/GUI/Radio',-2,-1)[0]
      if [@x,@y,@choices.length] != @last
        @ys.clear
        @choices.each{|ch| w=GUI::text_width(ch) ; @width=w+16+img.width if w+img.width>@width ; @ys << ((8+(i=@choices.index(ch)*FONT_SIZE))...(8+i+img.height)).to_a}
      end
      
      if !@changing and key_press(MsLeft) and $screen.mouse_x.between?(@x+8, @x+@width-4) and the_y=@ys.find{|y| y.include?($screen.mouse_y.to_i-@y)}
        choice=@choice
        @choice=@ys.index(the_y)
        @changed=true if @choice !=choice
        @changing=true
      elsif !key_press(MsLeft)
        @changing=nil
      end
      @last=[@x,@y,@choices.length]
    end

    def draw
      img=tls('core/GUI/Radio',-2,-1)[0]
      $screen.draw_quad(@x,@y,c=D_BCKG,@x+@width,@y,c,@x+@width,@y+@height,c,@x,@y+@height,c,@z+2)
      $screen.draw_quad(@x+4,@y+4,c=D_FRGND,@x+@width-4,@y+4,c,@x+@width-4,@y+@height-4,c,@x+4,@y+@height-4,c,@z+2)
      
      @choices.each_index{|i|
        fnt(FONT,FONT_SIZE).draw(@choices[i],@x+8+img.width+4,@y+6+i*FONT_SIZE,4,1,1,FONT_COLOR)
        tls('core/GUI/Radio',-2,-1)[@choice==i ? 1 : 0].draw(@x+8,@y+8+i*FONT_SIZE,@z+2)
      }
    end
    
    def value
      @choice
    end
    
    def value2
      @choices[@choice]
    end
  
    def value=(val)
      @choice=val
    end
  end

  class Dropdown < System
    attr_reader :choices,:changed
    def initialize(x,y,*choices)
      @x,@y,@choices=x,y,choices
      @z=1
      @choice=0
      @width=16
      @choices.each{|ch| if (w=GUI::text_width(ch)+12)>@width then @width=w+12 end}
      @last=@choices.length
      GUI::System.Push(self)
    end

    def update
      @changed=nil
      @choices.each{|ch| if (w=GUI::text_width(ch)+12)>@width then @width=w+12 end} if @last!=@choices.length
      @last=@choices.length
      
      if !@dropdown and key_press(MsLeft) and $screen.mouse_x.between?(@x, @x+@width+24) and $screen.mouse_y.between?(@y, @y+24)
        @dropdown=true
      elsif @dropdown and !@clicking and key_press(MsLeft)
        @dropdown=@clicking=@choosing
      elsif !key_hold(MsLeft)
        if @clicking and @choosing
          @dropdown=nil
          choice=@choice
          @choice=@choosing
          @changed=true if @choice !=choice
        end
        @clicking=@choosing=nil
      end
    end

    def draw
      $screen.draw_quad(@x,@y,c=D_BCKG,@x+@width,@y,c,@x+@width,@y+FONT_SIZE+8,c,@x,@y+FONT_SIZE+8,c,@z+2)
      $screen.draw_quad(@x+2,@y+2,c=(@dropdown ? SPECIAL_COLOR2 : L_FRGND),@x+@width-2,@y+2,c,@x+@width-2,@y+FONT_SIZE+6,c,@x+2,@y+FONT_SIZE+6,c,@z+2)
      
      $screen.draw_quad(@x+@width,@y,c=D_BCKG,@x+@width+24,@y,c,@x+@width+24,@y+24,c,@x+@width,@y+24,c,@z+2)
      $screen.draw_quad(@x+@width+2,@y+2,c=D_FRGND,@x+@width+22,@y+2,c,@x+@width+22,@y+22,c,@x+@width+2,@y+22,c,@z+2)
      if @dropdown
        $screen.draw_quad(@x+@width+4,@y+16,c=SPECIAL_COLOR,@x+@width+20,@y+16,c,@x+@width+12,@y+8,c,@x+@width+12,@y+8,c,@z+2)
      else
        $screen.draw_quad(@x+@width+4,@y+8,c=SPECIAL_COLOR,@x+@width+20,@y+8,c,@x+@width+12,@y+16,c,@x+@width+12,@y+16,c,@z+2)
      end
      
      fnt(FONT,FONT_SIZE).draw(@choices[@choice],@x+8,@y+4,@z+2,1,1,FONT_COLOR)
      if @dropdown
        $screen.draw_quad(@x,@y+24,c=D_BCKG,@x+@width,@y+24,c,@x+@width,@y+@choices.length*FONT_SIZE+26,c,@x,@y+@choices.length*FONT_SIZE+26,c,@z+3)
        $screen.draw_quad(@x+2,@y+24,c=L_FRGND,@x+@width-2,@y+24,c,@x+@width-2,@y+@choices.length*FONT_SIZE+24,c,@x+2,@y+@choices.length*FONT_SIZE+24,c,@z+3)
        
        mouseover=false
        if $screen.mouse_x.between?(@x, @x+@width) && $screen.mouse_y.between?(@y+24, @y+@choices.length*FONT_SIZE+23)
          @choosing=($screen.mouse_y.to_i-24-@y)/FONT_SIZE
          mouseover=true
        end
        
        if @choosing and key_hold(MsLeft) || mouseover
          y=24+FONT_SIZE*@choosing
          $screen.draw_quad(@x+2,@y+y,c=SPECIAL_COLOR2,@x+@width-2,@y+y,c,@x+@width-2,@y+y+FONT_SIZE,c,@x+2,@y+y+FONT_SIZE,c,@z+3)
        end
        @choices.each{|ch| fnt(FONT,FONT_SIZE).draw(ch,@x+8,@y+24+(i=@choices.index(ch))*FONT_SIZE,@z+3,1,1,FONT_COLOR)}
      end
    end
    
    def value
      @choice
    end
    
    def value2
      @choices[@choice]
    end
  
    def value=(val)
      @choice=val
    end
  end

  class Textbox < TextInput
    attr_accessor :x,:y,:z,:disabled,:inactive,:changed
    attr_reader :width
    def initialize(x,y,max,starttext=nil)
      super()
      @x,@y,@max,@starttext=x,y,max,starttext
      @z=1
      @width=GUI::text_width('m'*max)+8
      GUI::System.Push(self)
    end

    def update
      @changed=($screen.text_input==self and value != @lasttext)
      @lasttext2=@lasttext
      @lasttext=value
      $screen.text_input=nil if key_press(MsLeft) and $screen.text_input==self
      if key_press(MsLeft) and $screen.mouse_x.between?(@x, @x+@width+4) and $screen.mouse_y.between?(@y, @y+24)
        $screen.text_input=self
        self.selection_start=[(($screen.mouse_x-@x)/GUI::text_width('m')).round,self.text.length].min
        @clicked=true
        @starttext=nil
      end
      
      if @clicked and key_hold(MsLeft)
        self.caret_pos=[[(($screen.mouse_x-@x)/GUI::text_width('m')).round,self.text.length].min,0].max
      else
        @clicked=nil
      end
      
      return if $screen.text_input != self
      if key_hold(KbLeftControl) and key_press(KbA)
        self.selection_start=0
        self.caret_pos=self.text.length
      end
      
      if key_hold(KbLeftControl) and key_press(KbC)
        GUI::System.Clipboard=value[([self.selection_start,self.caret_pos].min..([self.selection_start,self.caret_pos].max-1))]
      end
      
      if key_hold(KbLeftControl) and key_press(KbX)
        GUI::System.Clipboard=value[([self.selection_start,self.caret_pos].min..([self.selection_start,self.caret_pos].max-1))]
        caret=[self.selection_start,self.caret_pos].min
        string=self.text
        string[([self.selection_start,self.caret_pos].min..([self.selection_start,self.caret_pos].max-1))]=""
        self.text=string
        self.caret_pos=self.selection_start=caret
      end
      
      if key_hold(KbLeftControl) and key_press(KbV)
        caret=[self.selection_start,self.caret_pos].min
        string=self.text
        string[([self.selection_start,self.caret_pos].min..([self.selection_start,self.caret_pos].max-1))]=""
        self.text=string
        self.caret_pos=self.selection_start=caret
        self.text=self.text.insert(self.caret_pos,GUI::System.Clipboard)
        self.caret_pos=self.selection_start=caret+GUI::System.Clipboard.length
      end
    end

    def draw
      if self.text.length==@max+1 #this happens when trying to write a letter to full text
        caret=self.caret_pos
        self.text=@lasttext2
        self.caret_pos=self.selection_start=caret-1
      end
      
      caret=self.caret_pos ; change=false
      while self.text.length>@max do self.text=self.text.chop ; change=true end
      while @starttext.length>@max do @starttext.chop! end if @starttext
      self.caret_pos=self.selection_start=[caret,self.text.length].min if change
      
      $screen.draw_quad(@x,@y,c=D_BCKG,@x+@width+8,@y,c,@x+@width+8,@y+FONT_SIZE+8,c,@x,@y+FONT_SIZE+8,c,@z+2)
      $screen.draw_quad(@x+2,@y+2,c=L_FRGND,@x+@width+6,@y+2,c,@x+@width+6,@y+FONT_SIZE+6,c,@x+2,@y+FONT_SIZE+6,c,@z+2)
      $screen.draw_quad(@x+4+GUI::text_width('m'*self.selection_start)+4,@y+4,c=SPECIAL_COLOR2,@x+4+GUI::text_width('m'*self.caret_pos)+4,@y+4,c,@x+4+GUI::text_width('m'*self.caret_pos)+4,@y+FONT_SIZE+4,c,@x+4+GUI::text_width('m'*self.selection_start)+4,@y+FONT_SIZE+4,c,@z+2) if $screen.text_input==self
      
      fnt(FONT,FONT_SIZE).draw(self.text,@x+8,@y+4,@z+2,1,1,FONT_COLOR)
      fnt(FONT,FONT_SIZE).draw(@starttext,@x+8,@y+4,@z+2,1,1,L_BCKG) if @starttext
      $screen.draw_line(@x+4+GUI::text_width('m'*self.caret_pos)+4,@y+4,c=FONT_COLOR,@x+4+GUI::text_width('m'*self.caret_pos)+4,@y+FONT_SIZE+4,c,@z+2) if $screen.text_input==self and $time%60<30
    end
    
    def value
      self.text
    end
  
    def value=(val)
      self.text=val
    end
  end

  class Spinner < System
    attr_reader :value,:changed
    attr_accessor :min,:max
    def initialize(x,y,min,max)
      @x,@y,@min,@max=x,y,min,max
      @z=1
      @value=@min
      @wait=0
      GUI::System.Push(self)
      @field=Textbox.new(@x,@y,[@min.to_s.length,@max.to_s.length].max)
      @width=@field.width+8
    end
  
    def update
      @changed=nil
      @wait+=1
      
      cnd=($screen.mouse_x.between?(@x+@width, @x+@width+24) and $screen.mouse_y.between?(@y, @y+24))
      if !@clicked and key_press(MsLeft) and cnd
        $screen.text_input=nil if $screen.text_input==@field
        @clicked=($screen.mouse_y<@y+12 ? :up : :down)
        value=@value
        @value=[[@value+(@clicked==:up ? 1 : -1),@min].max,@max].min
        @changed=true if @value !=value
        @wait=-30
      elsif key_hold(MsLeft) and cnd and @wait>0
        ch=(@wait>210 ? 1000 : @wait>150 ? 100 : @wait>90 ? 10 : 1)
        value=@value
        @value=[[@value+(@clicked==:up ? ch : -ch),@min].max,@max].min
        @changed=true if @value !=value
      elsif !key_hold(MsLeft)
        @clicked=nil
      end
      
      if $screen.text_input==@field
        @value=[[@field.text.to_i,@min].max,@max].min
      elsif $screen.text_input != @field
        @field.text=@value
      end
    end
  
    def draw
      $screen.draw_quad(@x+@width,@y,c=(@clicked==:up ? D_FRGND : D_BCKG),@x+@width+24,@y,c,@x+@width+24,@y+12,c,@x+@width,@y+12,c,@z+2)
      $screen.draw_quad(@x+@width+2,@y+2,c=(@clicked==:up ? D_BCKG : D_FRGND),@x+@width+22,@y+2,c,@x+@width+22,@y+10,c,@x+@width+2,@y+10,c,@z+2)
      
      $screen.draw_line(@x+@width+6,@y+7,c=(@clicked==:up || @value==@max ? SPECIAL_COLOR2 : SPECIAL_COLOR),@x+@width+12,@y+3,c,@z+2)
      $screen.draw_line(@x+@width+12,@y+3,c,@x+@width+18,@y+7,c,@z+2)
      $screen.draw_line(@x+@width+6,@y+8,c,@x+@width+12,@y+4,c,@z+2)
      $screen.draw_line(@x+@width+12,@y+4,c,@x+@width+18,@y+8,c,@z+2)
      
      $screen.draw_quad(@x+@width,@y+12,c=(@clicked==:down ? D_FRGND : D_BCKG),@x+@width+24,@y+12,c,@x+@width+24,@y+24,c,@x+@width,@y+24,c,@z+2)
      $screen.draw_quad(@x+@width+2,@y+14,c=(@clicked==:down ? D_BCKG : D_FRGND),@x+@width+22,@y+14,c,@x+@width+22,@y+22,c,@x+@width+2,@y+22,c,@z+2)
      
      $screen.draw_line(@x+@width+6,@y+16,c=(@clicked==:down || @value==@min ? SPECIAL_COLOR2 : SPECIAL_COLOR),@x+@width+12,@y+20,c,@z+2)
      $screen.draw_line(@x+@width+12,@y+20,c,@x+@width+18,@y+16,c,@z+2)
      $screen.draw_line(@x+@width+6,@y+17,c,@x+@width+12,@y+21,c,@z+2)
      $screen.draw_line(@x+@width+12,@y+21,c,@x+@width+18,@y+17,c,@z+2)
    end
  
    def value=(val)
      @value=val
    end
    
    def x=(value)
      @x=value
      @field.x=value
    end
    
    def y=(value)
      @y=value
      @field.y=value-1
    end
    
    def z=(value)
      @z=value
      @field.z=value
    end
    
    def disabled=(value)
      @disabled=value
      @field.disabled=value
    end
  end

  class Scrollbar < System
    attr_writer :max
    def initialize(x,y,max,length=0,size=1)
      @x,@y,@length,@size=x,y,length+12,size
      self.max=max
      @z=1
      @value=0
      GUI::System.Push(self)
    end

    def update
      return if GUI::System.Focus?(self)
      height=[(@size.to_f/(@max+@size))*(@length-12),@length-12].min
      y=@value*(height/@size)
      
      if !@clicking and key_press(MsLeft) and $screen.mouse_x.between?(@x,@x+23) and $screen.mouse_y.between?(@y,@y+12)
        @clicking=:up
        @value-=1 if @value>0
      elsif !@clicking and key_press(MsLeft) and $screen.mouse_x.between?(@x,@x+23) and $screen.mouse_y.between?(@y+@length,@y+@length+12)
        @clicking=:down
        @value+=1 if @value<@max
      elsif !@clicking and key_press(MsLeft) and $screen.mouse_x.between?(@x,@x+23) and $screen.mouse_y.between?(@y+12+y,@y+12+y+height)
        @clicking=$screen.mouse_y-y
      elsif !@clicking and key_press(MsLeft) and $screen.mouse_x.between?(@x,@x+23) and $screen.mouse_y.between?(@y+12,@y+11+@length)
        @value-=@size if $screen.mouse_y<@y+y+12
        @value+=@size if $screen.mouse_y>@y+y+12
        @value=[[@value,0].max,@max].min
      elsif !key_hold(MsLeft)
        @clicking=nil
      end
      
      if ![nil,:up,:down].include? @clicking
        @value=[[(($screen.mouse_y-@clicking)/(height/@size)).to_i,0].max,@max].min
      end
    end

    def draw
      height=12
      #top arrow
      $screen.draw_quad(@x,@y,c=((@clicking==:up or @value==0) ? L_FRGND : D_BCKG),@x+24,@y,c,@x+24,@y+height,c,@x,@y+height,c,@z+2)
      $screen.draw_quad(@x+2,@y+2,c=((@clicking==:up or @value==0) ? D_BCKG : D_FRGND),@x+22,@y+2,c,@x+22,@y+height-2,c,@x+2,@y+height-2,c,@z+2)
      $screen.draw_quad(@x+4,@y+height-4,c=((@clicking==:up or @value==0) ? SPECIAL_COLOR2 : SPECIAL_COLOR),@x+20,@y+height-4,c,@x+12,@y+height-8,c,@x+12,@y+height-8,c,@z+2)
      #bottom arrow
      $screen.draw_quad(@x,@y+@length,c=((@clicking==:down or @value==@max) ? L_FRGND : D_BCKG),@x+24,@y+@length,c,@x+24,@y+@length+height,c,@x,@y+@length+height,c,@z+2)
      $screen.draw_quad(@x+2,@y+@length+2,c=((@clicking==:down or @value==@max) ? D_BCKG : D_FRGND),@x+22,@y+@length+2,c,@x+22,@y+@length+height-2,c,@x+2,@y+@length+height-2,c,@z+2)
      $screen.draw_quad(@x+4,@y+@length+4,c=((@clicking==:down or @value==@max) ? SPECIAL_COLOR2 : SPECIAL_COLOR),@x+20,@y+@length+4,c,@x+12,@y+@length+8,c,@x+12,@y+@length+8,c,@z+2)
      #background arrow
      $screen.draw_quad(@x,@y+12,c=D_BCKG,@x+24,@y+12,c,@x+24,@y+@length,c,@x,@y+@length,c,@z+2)
      $screen.draw_quad(@x+2,@y+12,c=L_BCKG,@x+22,@y+12,c,@x+22,@y+@length,c,@x+2,@y+@length,c,@z+2)
      #scroller
      height=[(@size.to_f/(@max+@size))*(@length-12),@length-12].min
      height2=[height.round,4].max
      height3=height/@size
      y=[@value*height3,@length-14].min
      $screen.draw_quad(@x,@y+12+y,c=D_FRGND,@x+24,@y+12+y,c,@x+24,@y+12+y+height2,c,@x,@y+12+y+height2,c,@z+2)
      $screen.draw_quad(@x+4,@y+16+y,c=L_FRGND,@x+20,@y+16+y,c,@x+20,@y+8+y+height2,c,@x+4,@y+8+y+height2,c,@z+2)
    end
    
    def value
      @value
    end
  
    def value=(val)
      @value=val
    end
    
    def max=(value)
      @max=[0,value].max
    end
  end

  class List < System
    attr_reader :choices,:changed
    def initialize(x,y,max,*choices)
      @x,@y,@choices=x,y,choices
      @z=1
      @choice=0
      @max=max
      @width=16
      @choices.each{|ch| if (w=GUI::text_width(ch)+12)>@width then @width=w+12 end}
      @scroll=Scrollbar.new(@x+@width,@y,@choices.length-@max,@max*FONT_SIZE-16)
      GUI::System.Push(self)
    end

    def update
      @changed=nil
      @scroll.max=@choices.length-@max
      
      old=@choice
      if !@select and key_press(MsLeft) and $screen.mouse_x.between?(@x, @x+@width) and $screen.mouse_y.between?(@y, @y+@max*FONT_SIZE-1)
        @select=true
      elsif @select
        @choice=[($screen.mouse_y.to_i-@y)/FONT_SIZE+@scroll.value,@choices.length-1].min
        @select=nil if key_release(MsLeft)
      end
      
      if key_press(MsWheelDown) and @choice<@choices.length-1 and $screen.mouse_x.between?(@x, @x+@width) and $screen.mouse_y.between?(@y, @y+@max*FONT_SIZE-1)
        @choice+=1
        @scroll.value+=1 if @choice==@scroll.value+@max
      elsif key_press(MsWheelUp) and @choice>0 and $screen.mouse_x.between?(@x, @x+@width) and $screen.mouse_y.between?(@y, @y+@max*FONT_SIZE-1)
        @choice-=1
        @scroll.value-=1 if @choice==@scroll.value-1
      end
      @changed=true if old != @choice
    end

    def draw
      position=@scroll.value
      y=(@choice-position)*FONT_SIZE
      $screen.draw_quad(@x,@y,c=D_BCKG,@x+@width,@y,c,@x+@width,@y+FONT_SIZE*@max+8,c,@x,@y+FONT_SIZE*@max+8,c,@z+2)
      $screen.draw_quad(@x+2,@y+2,c=L_FRGND,@x+@width-2,@y+2,c,@x+@width-2,@y+FONT_SIZE*@max+6,c,@x+2,@y+FONT_SIZE*@max+6,c,@z+2)
      $screen.draw_quad(@x+2,@y+y+2,c=SPECIAL_COLOR2,@x+@width-2,@y+y+2,c,@x+@width-2,@y+y+FONT_SIZE+2,c,@x+2,@y+y+FONT_SIZE+2,c,@z+2) if (position...(position+@max)).include?(@choice)
      
      y=-1
      @choices[position...(position+@max)].each{|ch| y+=1; fnt(FONT,FONT_SIZE).draw(ch,@x+8,@y+4+y*FONT_SIZE,@z+3,1,1,FONT_COLOR)}
    end
    
    def value
      @choice
    end
    
    def value2
      @choices[@choice]
    end
  
    def value=(val)
      @choice=val
    end
    
    def disabled=(value)
      @disabled=value
      @scroll.disabled=value
    end
    
    def remove
      @scroll.remove
      super
    end
  end

  System.Init
end