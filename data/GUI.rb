module GUI
  D_BCKG= 0xff808000
  L_BCKG= 0xff008000
  D_FRGND= 0xffc0c000
  L_FRGND= 0xff00c000
  FONT_COLOR= 0xff000000
  FONT= default_font_name
  FONT_SIZE= 16

  class System
    attr_accessor :x,:y,:z,:disabled,:inactive
    def System.Init
      $GUI=[]
      4.times{|i|
      Img['GUI/Cursor'].clear(:color=>[D_BCKG,L_BCKG,D_FRGND,L_FRGND][i],:dest_select=>[[0]*3+[1],[0.25]*3+[1],[0.5]*3+[1],[0.75]*3+[1]][i],:tolerance=>0.1)
      Img['GUI/Close'].clear(:color=>[D_BCKG,L_BCKG,D_FRGND,L_FRGND][i],:dest_select=>[[0]*3+[1],[0.25]*3+[1],[0.5]*3+[1],[0.75]*3+[1]][i],:tolerance=>0.1)
      Img['GUI/Zip'].clear(:color=>[D_BCKG,L_BCKG,D_FRGND,L_FRGND][i],:dest_select=>[[0]*3+[1],[0.25]*3+[1],[0.5]*3+[1],[0.75]*3+[1]][i],:tolerance=>0.1)
      Tls['GUI/Check',-3,-1].each{|img| img.refresh_cache ; img.clear(:color=>[D_BCKG,L_BCKG,D_FRGND,L_FRGND][i],:dest_select=>[[0]*3+[1],[0.25]*3+[1],[0.5]*3+[1],[0.75]*3+[1]][i],:tolerance=>0.1)}
      Tls['GUI/Radio',-2,-1].each{|img| img.refresh_cache ; img.clear(:color=>[D_BCKG,L_BCKG,D_FRGND,L_FRGND][i],:dest_select=>[[0]*3+[1],[0.25]*3+[1],[0.5]*3+[1],[0.75]*3+[1]][i],:tolerance=>0.1)}
      Tls['GUI/Dropdown',-2,-2].each{|img| img.refresh_cache ; img.clear(:color=>[D_BCKG,L_BCKG,D_FRGND,L_FRGND][i],:dest_select=>[[0]*3+[1],[0.25]*3+[1],[0.5]*3+[1],[0.75]*3+[1]][i],:tolerance=>0.1)}
      }
    end
  
    def System.Update
      $GUI.each{|s| s.update if !s.disabled and !s.inactive}
    end
  
    def System.Draw
      $screen.flush
      $GUI.each{|s| s.draw if !s.disabled}
      $screen.flush
      Img['GUI/Cursor'].draw($screen.mouse_x,$screen.mouse_y,8)
    end
    
    def System.Z
      @@z||=0
      @@z+=1
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
  end
  
  class Window < System
    attr_accessor :docked,:nox
    def initialize(x,y,width,height,title,customization)
      @x,@y,@width,@height,@title=x,y,width,height+Img['GUI/Close'].height,title
      @texts=[] ; @separators=[] ; @objects={}
      customization.each{|custom| method(custom[0]).call(custom[1])}
      @z=GUI::System.Z
      @objects.each_value{|obj|
        obj[0].x=@x+4+obj[1]
        obj[0].y=@y+Img['GUI/Close'].height+obj[2]
        obj[0].z=@z
        obj[0].disabled=@disabled}
      $GUI << self
    end

    def update
      if Keypress[MsLeft]  && !GUI::System.Stick? && $screen.mouse_x>@x && $screen.mouse_x<@x+@width && $screen.mouse_y>@y && $screen.mouse_y<@y+Img['GUI/Close'].height or @mouse
        GUI::System.Stick(self)
        @z=GUI::System.Z
        @mouse||=[$screen.mouse_x-@x,$screen.mouse_y-@y]
        @x=$screen.mouse_x-@mouse[0] if !@docked
        @y=$screen.mouse_y-@mouse[1] if !@docked
        if !@nox and @mouse[0]>@width-Img['GUI/Close'].width then @mouse=nil ; @disabled=true ; GUI::System.Stick(nil) end
        (@mouse=nil ; GUI::System.Stick(nil)) if !Keypress[MsLeft]
      end
      @objects.each_value{|obj|
      obj[0].x=@x+4+obj[1]
      obj[0].y=@y+Img['GUI/Close'].height+obj[2]
      obj[0].z=@z
      obj[0].disabled=@disabled
      obj[0].inactive=nil}
      
      if @z != GUI::System.Z?
        @objects.each_value{|obj|
          obj[0].inactive=true}
      end
    end

    def draw
      img=Img['GUI/Close']
      $screen.draw_quad(@x,@y,c=(@z==GUI::System.Z? ? D_FRGND : D_BCKG),@x+@width,@y,c,@x+@width,@y+@height,c,@x,@y+@height,c,@z)
      $screen.draw_quad(@x+4,@y+img.height,c=L_BCKG,@x+@width-4,@y+img.height,c,@x+@width-4,@y+@height-4,c,@x+4,@y+@height-4,c,@z)
      img.draw(@x+@width-img.width,@y,@z+0.1) if !@nox
      Fnt[FONT,FONT_SIZE].draw(@title,@x+4,@y,@z+0.1,1,1,FONT_COLOR)
      @texts.each{|txt|
        Fnt[FONT,FONT_SIZE].draw(txt[0],@x+4+txt[1],@y+16+txt[2],@z+0.1,1,1,FONT_COLOR)}
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
  end

  class Button < System
    def initialize(x,y,text)
      @x,@y,@text=x,y,text
      @z=1
      $GUI << self
    end

    def update
      @clicked=@value=nil
      if !@clicking and Keypress[MsLeft] and $screen.mouse_x>@x and $screen.mouse_x<@x+Fnt[FONT,FONT_SIZE].text_width(@text)+8 and $screen.mouse_y>@y and $screen.mouse_y<@y+24
        @value=@clicked=true
        @clicking=true
      elsif !Keypress[MsLeft]
        @clicking=nil
      end
    end

    def draw
      width=Fnt[FONT,FONT_SIZE].text_width(@text)+8
      $screen.draw_quad(@x,@y,c=if @clicking then D_FRGND else L_FRGND end,@x+width+8,@y,c,@x+width+8,@y+FONT_SIZE+8,c,@x,@y+FONT_SIZE+8,c,@z+0.2)
      $screen.draw_quad(@x+4,@y+4,c=if @clicking then L_FRGND else D_FRGND end,@x+width+4,@y+4,c,@x+width+4,@y+FONT_SIZE+4,c,@x+4,@y+FONT_SIZE+4,c,@z+0.2)
      Fnt[FONT,FONT_SIZE].draw(@text,@x+8,@y+4,@z+0.2,1,1,FONT_COLOR)
    end
    
    def value
      @clicked
    end
  
    def value=(val)
      @clicked=val
    end
  end

  class Zip < System
    def initialize(x,y,max,unit=1)
      @x,@y,@max,@unit=x,y,max,unit
      @z=1
      @value=0
      $GUI << self
    end
  
    def update
      if Keypress[MsLeft] && $screen.mouse_x>@x && $screen.mouse_x<@x+@max*@unit && $screen.mouse_y>@y-Img['GUI/Zip'].height/2 && $screen.mouse_y<@y+Img['GUI/Zip'].height/2 or @changing
        @changing=true
        @value=[[$screen.mouse_x-@x,0].max,@max*@unit].min.to_i/@unit
        @changing=nil if !Keypress[MsLeft]
      end
    end
  
    def draw
      $screen.draw_line(@x,@y,c=D_FRGND,@x+@max*@unit,@y,c,@z+0.2)
      $screen.draw_line(@x,@y+1,c=L_FRGND,@x+@max*@unit,@y+1,c,@z+0.2)
      Img['GUI/Zip'].draw(@x+@value*@unit-Img['GUI/Zip'].width/2,@y-Img['GUI/Zip'].height/2+1,@z+0.2)
      Fnt[FONT,FONT_SIZE].draw_rel(@value,@x+@value*@unit,@y-Img['GUI/Zip'].height/2,@z+0.3,0.5,1,1,1,FONT_COLOR)
    end
    
    def value
      @value
    end
  
    def value=(val)
      @value=val
    end
  end

  class Check < System
    def initialize(x,y,negateable=nil)
      @x,@y,@negateable=x,y,negateable
      @z=1
      $GUI << self
    end

    def update
      img=Tls['GUI/Check',-3,-1][0]
      if !@changing and Keypress[MsLeft] and $screen.mouse_x>@x and $screen.mouse_x<@x+img.width and $screen.mouse_y>@y and $screen.mouse_y<@y+img.width
        @value=@state=if @state==nil then true elsif @state==true and @negateable then false elsif @state=true && !@negateable or @state==false then nil end
        @changing=true
      elsif !Keypress[MsLeft]
        @changing=nil
      end
    end

    def draw
      Tls['GUI/Check',-3,-1][[nil,true,false].index(@state)].draw(@x,@y,@z+0.2)
    end
    
    def value
      @state
    end
  
    def value=(val)
      @state=val
    end
  end

  class Radio < System
    attr_reader :choices
    def initialize(x,y,choices)
      @x,@y,@choices=x,y,choices
      @z=1
      @choice=0
      @width=16
      @height=@choices.length*FONT_SIZE+12
      @ys=[]
      img=Tls['GUI/Radio',-2,-1][0]
      @choices.each{|ch| w=Fnt[FONT,FONT_SIZE].text_width(ch) ; @width=w+16+img.width if w+img.width>@width ; @ys << ((8+(i=@choices.index(ch)*FONT_SIZE))...(8+i+img.height)).to_a}
      $GUI << self
    end

    def update
      @choices.each{|ch| w=Fnt[FONT,FONT_SIZE].text_width(ch) ; @width=w+16+img.width if w+img.width>@width ; @ys << ((8+(i=@choices.index(ch)*FONT_SIZE))...(8+i+img.height)).to_a}
      @last=@choices.length
      
      img=Tls['GUI/Radio',-2,-1][0]
      if !@changing and Keypress[MsLeft] and $screen.mouse_x>@x+8 and $screen.mouse_x<@x+8+img.width and the_y=@ys.find{|y| y.include?($screen.mouse_y.to_i-@y)}
        @choice=@ys.index(the_y)
        @changing=true
      elsif !Keypress[MsLeft]
        @changing=nil
      end
    end

    def draw
      img=Tls['GUI/Radio',-2,-1][0]
      $screen.draw_quad(@x,@y,c=D_BCKG,@x+@width,@y,c,@x+@width,@y+@height,c,@x,@y+@height,c,@z+0.2)
      $screen.draw_quad(@x+4,@y+4,c=L_BCKG,@x+@width-4,@y+4,c,@x+@width-4,@y+@height-4,c,@x+4,@y+@height-4,c,@z+0.2)
      @choices.each{|ch| Fnt[FONT,FONT_SIZE].draw(ch,@x+8+img.width,@y+4+(i=@choices.index(ch))*FONT_SIZE,4,1,1,FONT_COLOR) ; Tls['GUI/Radio',-2,-1][@choice==i ? 1 : 0].draw(@x+8,@y+8+i*FONT_SIZE,@z+0.2)}
    end
    
    def value
      @choice
    end
  
    def value=(val)
      @choice=val
    end
  end

  class Dropdown < System
    attr_reader :choices
    def initialize(x,y,choices)
      @x,@y,@choices=x,y,choices
      @z=1
      @value=@choice=0
      @width=16
      @choices.each{|ch| if (w=Fnt[FONT,FONT_SIZE].text_width(ch)+12)>@width then @width=w+12 end}
      @last=@choices.length
      $GUI << self
    end

    def update
      @choices.each{|ch| if (w=Fnt[FONT,FONT_SIZE].text_width(ch)+12)>@width then @width=w+12 end} if @last!=@choices.length
      @last=@choices.length
      
      img=Tls['GUI/Dropdown',-2,-2][0]
      if !@dropdown and !@clicking and Keypress[MsLeft] and $screen.mouse_x>@x+@width and $screen.mouse_x<@x+@width+img.width and $screen.mouse_y>@y and $screen.mouse_y<@y+img.height
        @dropdown=@clicking=true
      elsif @dropdown and !@clicking and Keypress[MsLeft] and @choosing
        @value=@choice=@choosing
        @clicking=true
        @dropdown=nil
      elsif @dropdown and !@clicking and Keypress[MsLeft]
        @clicking=true
        @dropdown=nil
      elsif !Keypress[MsLeft]
        @clicking=nil
      end
    end

    def draw
      img=Tls['GUI/Dropdown',-2,-2][0]
      $screen.draw_quad(@x,@y,c=D_BCKG,@x+@width,@y,c,@x+@width,@y+FONT_SIZE+8,c,@x,@y+FONT_SIZE+8,c,@z+0.2)
      $screen.draw_quad(@x+4,@y+4,c=L_BCKG,@x+@width-4,@y+4,c,@x+@width-4,@y+FONT_SIZE+4,c,@x+4,@y+FONT_SIZE+4,c,@z+0.2)
      Tls['GUI/Dropdown',-2,-2][@dropdown ? 1 : 0].draw(@x+@width,@y,@z+0.2)
      Fnt[FONT,FONT_SIZE].draw(@choices[@choice],@x+8,@y+4,@z+0.2,1,1,FONT_COLOR)
      if @dropdown
        $screen.draw_quad(@x,@y+img.height,c=D_BCKG,@x+@width,@y+img.height,c,@x+@width,@y+@choices.length*FONT_SIZE+img.height+2,c,@x,@y+@choices.length*FONT_SIZE+img.height+2,c,@z+0.2)
        $screen.draw_quad(@x+2,@y+img.height,c=L_BCKG,@x+@width-2,@y+img.height,c,@x+@width-2,@y+@choices.length*FONT_SIZE+img.height,c,@x+2,@y+@choices.length*FONT_SIZE+img.height,c,@z+0.2)
        if $screen.mouse_x>@x and $screen.mouse_x<@x+@width and $screen.mouse_y>@y+img.height and $screen.mouse_y<@y+@choices.length*FONT_SIZE+img.height
          @choosing=($screen.mouse_y.to_i-img.height-@y)/FONT_SIZE
          y=img.height+FONT_SIZE*(($screen.mouse_y.to_i-@y-img.height)/FONT_SIZE)
          $screen.draw_quad(@x+1,@y+y,c=L_FRGND,@x+@width-1,@y+y,c,@x+@width-1,@y+y+FONT_SIZE,c,@x+1,@y+y+FONT_SIZE,c,@z+0.2)
        end
        @choices.each{|ch| Fnt[FONT,FONT_SIZE].draw(ch,@x+8,@y+img.height+(i=@choices.index(ch))*FONT_SIZE,@z+0.2,1,1,FONT_COLOR)}
      end
    end
    
    def value
      @choice
    end
  
    def value=(val)
      @choice=val
    end
  end

  class Textbox < TextInput
    attr_accessor :x,:y,:disabled,:inactive
    def initialize(x,y,max)
      super()
      @x,@y,@max=x,y,max
      @z=1
      @width=Fnt[FONT,FONT_SIZE].text_width('G'*max)+8
      $GUI << self
    end

    def update
      $screen.text_input=nil if Keypress[MsLeft,false] and $screen.text_input==self
      if !@clicked and Keypress[MsLeft] and $screen.mouse_x>@x and $screen.mouse_x<@x+@width+4 and $screen.mouse_y>@y and $screen.mouse_y<@y+24
        $screen.text_input=self
        self.selection_start=[(($screen.mouse_x-@x)/Fnt[FONT,FONT_SIZE].text_width('G')).to_i,self.text.length].min
        @clicked=true
      elsif !Keypress[MsLeft]
        @clicked=nil
      end
      if @clicked and $screen.text_input==self
        self.caret_pos=[[(($screen.mouse_x-@x)/Fnt[FONT,FONT_SIZE].text_width('G')).to_i,self.text.length].min,0].max
      end
    end

    def draw
      caret=self.caret_pos ; change=false
      while self.text.length>@max do self.text=self.text.chop ; change=true end
      self.caret_pos=self.selection_start=[caret,self.text.length].min if change
      $screen.draw_quad(@x,@y,c=D_BCKG,@x+@width+8,@y,c,@x+@width+8,@y+FONT_SIZE+10,c,@x,@y+FONT_SIZE+10,c,@z+0.2)
      $screen.draw_quad(@x+4,@y+4,c=L_BCKG,@x+@width+4,@y+4,c,@x+@width+4,@y+FONT_SIZE+6,c,@x+4,@y+FONT_SIZE+6,c,@z+0.2)
      $screen.draw_quad(@x+4+Fnt[FONT,FONT_SIZE].text_width('G'*self.selection_start),@y+4,c=L_FRGND,@x+4+Fnt[FONT,FONT_SIZE].text_width('G'*self.caret_pos),@y+4,c,@x+4+Fnt[FONT,FONT_SIZE].text_width('G'*self.caret_pos),@y+FONT_SIZE+6,c,@x+4+Fnt[FONT,FONT_SIZE].text_width('G'*self.selection_start),@y+FONT_SIZE+6,c,@z+0.2) if $screen.text_input==self
      x=0
      self.text.each_char{|char| Fnt[FONT,FONT_SIZE].draw(char,@x+8+x*Fnt[FONT,FONT_SIZE].text_width("G"),@y+6,@z+0.2,1,1,FONT_COLOR) ; x+=1}
      $screen.draw_line(@x+6+Fnt[FONT,FONT_SIZE].text_width('G'*self.caret_pos),@y+4,c=D_FRGND,@x+6+Fnt[FONT,FONT_SIZE].text_width('G'*self.caret_pos),@y+FONT_SIZE+6,c,@z+0.2) if $screen.text_input==self and $count%60<30
    end
    
    def value
      self.text
    end
  
    def value=(val)
      self.text=val
    end
  end

  class Number < System
    def initialize(x,y,min,max)
      @x,@y,@min,@max=x,y,min,max
      @z=1
      @value=0
      @wait=0
      @width=Fnt[FONT,FONT_SIZE].text_width('9'*([@min.to_s.length,@max.to_s.length].max+1))+4
      $GUI << self
    end
  
    def update
      img=Tls['GUI/Dropdown',-2,-2][0]
      cnd=($screen.mouse_x>@x+@width and $screen.mouse_x<@x+@width+img.width and $screen.mouse_y>@y and $screen.mouse_y<@y+img.height)
      @wait-=1
      if !@clicked and Keypress[MsLeft] and cnd
        @clicked=($screen.mouse_y<@y+img.height/2 ? :up : :down)
        @value=[[@value+(@clicked==:up ? 1 : -1),@min].max,@max].min
        @wait=30
      elsif Keypress[MsLeft] and cnd and @wait<0
        ch=if @wait<-210 then 1000 elsif @wait<-150 then 100 elsif @wait<-90 then 10 else 1 end
        @value=[[@value+(@clicked==:up ? ch : -ch),@min].max,@max].min
      elsif !Keypress[MsLeft]
        @clicked=nil
      end
    end
  
    def draw
      img=Tls['GUI/Dropdown',-2,-2][0]
      $screen.draw_quad(@x,@y,c=D_BCKG,@x+@width+4,@y,c,@x+@width+4,@y+24,c,@x,@y+24,c,@z+0.2)
      $screen.draw_quad(@x+4,@y+4,c=L_BCKG,@x+@width,@y+4,c,@x+@width,@y+20,c,@x+4,@y+20,c,@z+0.2)
      Fnt[FONT,FONT_SIZE].draw(@value,@x+8,@y+4,@z+0.2,1,1,FONT_COLOR)
      Tls['GUI/Dropdown',-2,-2][@clicked==:up ? 1 : 2].draw(@x+@width+4,@y,@z+0.2,1,0.5)
      Tls['GUI/Dropdown',-2,-2][@clicked==:down ? 3 : 0].draw(@x+@width+4,@y+img.height/2,@z+0.2,1,0.5)
    end
  
    def value=(val)
      @value=val
    end
  end
end