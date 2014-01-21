Sapphire (source version) 

The 'source' includes:
- source code (with Template files)
- exe
- icon file
- batch compiler for Windows/Ocra (pretty useless)
- SciTe (Windows)
- examples directory
- examples zip
- this file

Sapphire is:
- stand-alone Ruby for Windows, including gems for making games
- template maker to start developing games with Ruby/Gosu easier


If you are Windows, you can use the exe. If not, you need Ruby and run/compile Sapphire.rb to have same functionality.
And having Ruby installed, the only interesting thing you can do is the !template command (see below). Just run Sapphire.rb
This file describes mainly the Template features.


Specjal commands:
!scite - opens text editor (Windows only)
!examles - crates zip of examples how to use template
!template - creates template for game
  You can specify title by typing it after space (!template My_Title)

Template is an empty game project with useful classes to help developing.
__________________________________________________________________________________________________________

Template documentation:

Upon creating, template includes (Title).rb file and 'data' directory.
Inside data, there are few more directories:
scripts - here is code of your project ; all files placed here will be loaded automatically
core - contains system image files and some others ; modify your GUI graphics here
gfx - default directory for all graphics ; any loaded image will be first looked for in this directory (and sub-folders if you specify path), but you can place images anywhere in 'data' directory
sfx - default for sound samples
music - default for music
fades - all fading effects are stored here (see: somewhere below)


Global variables used:
- $state - current state of game, which is being updated and drawn ; $state= for changing game states
- $screen - window instance ; useful when you need mouse position etc.
- $time- global frame counter ; non-moldifable, use it like Gosu.milliseconds
- $enable_gui - set true to enable GUI
- $premusic - used by music intro, not you


Code files: (number is for class index below)
- (Title).rb  // 1
    Game's core, which loads scripts and has Window's class

- specjal.rb  // 2,3,4,5,6
    Major file with helper classes. Manages resources, buttons etc.
    Stop_Music - method that stops any song playing

- game.rb  // 7
    File for main game's state. Manages entities etc.

- utility&fx.rb  // 8,9,10,11,12,13,14,15,16,17,18,19,20,21,22
    Tools for easy advanced entity control and classes taking care of simple effects, like particles etc. Also some collision classes
    
  objects.rb // 23
    You can put your objects here

- GUI
    Contains GUI module


Classe index (note that not every single variable is described as they are repeating ; there are also some references to files you should look with specific lines/methods ; all classes are explained in examples)
1.Main
Window class responsible for updating and drawing game states and reading input.

 def button_down/up(id)
 Checks if specified key is pressed/released. Needs to be placed in state class to work
 
 def fade_out(effect, speed, solid=:auto)
 Fades out screen and disables further drawing. Used: $screen.fade_out
 effect - name of effect in 'data/fades'. Images should be grayscale gradient/pattern/whatever, where colors with greater luminance (brighter) will fade out first
 speed - speed of fading, 1000 meaning instant and 1 is about 15 seconds
 solid - true or false ; defines if fading effect should be completely opaque (solid) or fade smoothly ; when nothing is given, it will use default value
 
 def fade_in(effect, speed, solid=:auto)
 Same as fade out, but fades in and brighter colors appear last ; also, continues the drawing loop
 
 def unfade
 Continue the drawing loop without fading in
 
 def fade_mode
 Default value for 'solid' argument

2.Keypress
Used for input checking, allows to bind keys to symbols

  def Keypress.[](id,repeat)
  id - Gosu::Button or symbol
  repeat - when false, key is triggered once until releasing it
  Symbol will be used as key for control hash, defined with methods below

  def Keypress.Any
  Returns key pressed in current frame (button_down(id))
  
  def Keypress.Define(keys)
  Defines controls (used in main.rb). keys must be a {:symbol=>Gosu::Button} hash
  
  def Keypress.Set(key,new)
  Binds one key, where 'key' is :symbol of key and 'new' is Button to be stored

3.Img \ Snd \ Msc
Loads specified resoure and saves in memory for re-use

  def .[](name,/tileable/,/pre/)
  Use: Img['space'] so it will load 'space.png' from 'data/gfx' etc.
  name - path to resource
  tileable - used only for Img, true if image has to be tileable
  pre - apply intro to music. It will be played at the beginning and then the actual music is looped. Intro must be separate file named '(music_name)-pre'. Using :auto will seek automatically if there's intro available
  Images need to be .png , music and sound .ogg
  
for Msc

  def Msc.Stop
  Stops any music playing making sure you won't cause an exception
  
  def Msc.Pause
  Pauses any music
  
  def Msc.Resume
  Resumes paused music, taking care of any intros, so it will loop right

4.Tls
Loads tiles from image

  def Tls.[](name,width, height=width, tileable=false)
  width/height - size per tile, lower than 0 splits image into width/height tiles ; ommiting width will make square tiles

5.Fnt
Loads fonts

  def Fnt.[](name,size)
  name - path to font or name of .ttf file from system's fonts ; if specified as Tls array, makes a BitmapFont (see below)
  size - height of the font or array with order of characters for BitmapFont (see below)

6.BitmapFont
Specjal class for custom fonts
see: specjal.rb 154 for some customization

  def initialize(name,characters)
  name - array of images (use Tls method here)
  characters - array of characters as they are ordered in font's image. There's no difference in upcase or downcase chars

  def draw(x,y,z,args)
  args - hash arguments:
    :scalex/scaley - scale of characters
    :xspacing/yspacing - space between letters, defaultly is letter's size
    :max - maximal width of text in one line
    :align - :right or :center, no support for multiline text (yet?)
    :color - works best for greyscale images. Gosu::Color or hex 0xaarrggbb

6.Entity
Main class for game objects. Every object you make should inherit from Entity to provide these methods
see: specjal.rb 184 to define entity groups

  @x,@y - they are accessors by default
  @stop (accessor) - prevents entity update
  @invisible (accessor) - skips entity in drawing
  @removed (reader) - entity was removed (see below)
  @spawn_time (reader) - $time value when object was initialized. May be used for counters etc. ($time-@spawn_time is a lifetime value)

  def init(types)
  Pushes entity to game's entity array, so it's being updated. Use types arrray for grouping entities for easier managing
  Entity initialized again will have @removed variable set to nil

  def remove
  Deletes entity from game's entity array and all group arrays ; note that entity will vanish at the end of update cycle. Calling this sets @removed variatble to true on first ; entity can be initialized again if still stored somewhere

  def gravity(width,height,gravity)
  Method for simple falling physics
  width/height - size of object. When no height is give, it will take width value

7.Game
Default state class for handling game action. Manages in-game objects, provides useful methods. Just copy it when you need more states like this (for menu maybe)
see: game.rb 5 to customize effects
use intialize update and draw methods as comments say, so you can add your logic

  @lighting_enabled - if true, screen will darken out and Lights will be enabled (see: 20.Light class)

  def solid?
  Method to check if current coordinates are solid. Needs to be manually defined

  def reset
  Deletes all in-game entities
  
  def missing?(entity)
  Checks if entity is removed
  
  def find(group) {block}
  Searchs entitiy passing specified block. If no group is given, it will process through all entities

  def flash(color,speed,starting)
  Makes simple flash effect
    color - color of effect
    speed - how fast effect proceeds (255 means instant)
    starting - when true, screen is faded gradually, false means instant clear and then fade out of flash

  def shake(max,time,num)
  Makes simple shake effect ; shakes current state's Camera ; creates black frame if shaking beyond boundaries
    max - amplitude of oscillation
    time - number of frames between changing position
    num - number of shakes
    
  def set_camera(camera)
  Changes game's camera to given object (instance of Camera class)
  
  def set_default_camera(camera)
  Changes game's default camera to given one
  
  def default_camera
  Changes current camera to the default one
  
  def play(sample, x, y, volume)
  Plays sample somewhere, so it's volume and panning depends on disance from camera
  sample - name of sample
  x/y - coordinates of source
  volume - maximal radius at which the sample is heard

8.Counter
Object used for countdowns

  @finished (reader) - true if time reaches 0
  @time (reader) - current time

  def initialize(time)
  time - number of frames (ticks) to count

  def image(h,m,s,hs)
  Returns string which converts time into hours, minutes, seconds and hundreth of seconds (use variables to specify display)

9.Mover
Basic object to move group of entities together

  def initialize(entities, speed_x, speed_y)
  entities - array of entities
  speed_x/y - speed of moving

10.Flasher
Toggles entities' @invisible variable to make them flash effect

  def initialize(entities,time1,time2)
  time1/time2 - how often variable is toggling

11.Delayer
Slows entities' update for certain ammount of frames making a lag/slow motion effect

  def initialize(entities, time)
  time - lenght of lag in frames

12.Particle
Simple falling object, may be use eg. for crashing glass

  def initialize(x,y,z,img,vx,vy,args)
  img - name/path to image or array for tile values (["imagename" ,w ,h , id] instead of Tls method)
  vx/vy - initial speed
  args - hash arguments:
    :angle - initial angle of image (default: 0)
    :rotate - speed of image's rotating
    :scalex/:scaley - objects scale
    :color - color for image

13.Trail
Single animation sequence, which disappears after finishing

  def initialize(x,y,z,tiles,sequence,time,args)
  tiles - not Tls, but simple array (see: Particle)
  time - frame length of each frame
  args - :scalex, :scaley, :color
    :sequence - array of numbers, corresponding for frames in spriteset. Used for custom animation order
    :repeat - number of times to repeat sequence

14.Trace
Single image, which fades out particular time

  def initialize(x,y,img,speed,args={})
  img - see: Particle
  speed - speed of fading (max 255)
  args - :angle,:scalex,:scaley
    :color (MUST be Gosu::Color)
    :inverted - fades in instead of out

15.Combo
Used for reading key sequences

  @trigger (reader) - changes to true when combo is successful ; lasts for 1 frame (tick)

  def initialize(timeout,sequence)
  timeout - number of frames before combo cancels
  sequence - array of buttons or defined key symbols
  

Note: Collision classes are not inherits of Entity and they provide only readers for @x and @y
16.Collision_Box
For bounding box collision detection ; attach it to object with the note that it's position is centered

  @vectors (reader) - array of positions of edges in order: [x1, y1, x2, y2, x3, y3, x4, y4]
  @w,@h (writer/reader) - size of box
  
  def initialize(x,y,w,h,a)
  x,y - coordinates of the center
  w,h - width and height of box
  a - angle of box, around center
  
  def collides?(col)
  Returns true if box intersects with col (col is either Collision_Box, Collision_Ball or Collission_Group)
  
  def set(x,y,a)
  Binds new values for x,y and angle ; use it to follow object box is attached
  
  def move(x,y,a)
  Adds given values to x,y and angle
  
17.Collision_Ball
For bounding sphere (circle) collision detection ; attach it to object

  @r (writer/reader) - radius of ball
  
  def initialize(x,y,r)
  x,y - coordinates of the center
  r - radius
  
  def collides?(col)
  
  def set(x,y)
  Binds new values for x,y ; use it to follow object box is attached ; trying to set angle like in box, does nothing
  
  def move(x,y)
  Adds given values to x,y
  
18.Collision_Group
Group of balls and boxes ; they will move relatively to group position

  @c (reader) - array of colliders attached
  
  def initialize(x,y,a,*c)
  x,y - coordinates of group
  a - angle
  c - array of colliders
  
  def collides?(col)
  Checks if any of attached colliders intersect with col
  
  def set(x,y,a)
  Binds new values for x,y and angle ; children colliders will move accordingly also taking care of angle
  
  def move(x,y,a)
  Adds given values to x,y and angle of children colliders, also moving them accordingly
  
19.Camera
Class dedicated to screen control in Game class ; see: 7.Game class to see how to set camera

  def initialize(x, y)
  Screen will be centered around x,y (so the camera is in the middle of screen)
  
  def follow(entity, smooth)
  entity - camera will follow entity given
  smooth - integer, makes camera follow entity with given speed instead of instantly
  
  def move(x,y,speed)
  Camera will move to given position with given speed
  
  def scroll(vx,vy)
  Camera will move constantly with given speeds
  
  def boundary(min_x, min_y, max_x, max_y)
  Sets the boundary to the camera so top of the screen will never cross min_y etc.
  
  def offset(x, y)
  Sets the x and y offsets of camera, so will not center around given object etc.
  
  def pos_x/pos_y
  Returns position of left/top corner of the screen
  
  def shader(shader)
  Sets camera shader to given Ashton::Shader ; nil will disable
  
20.Light
To use with game's lighting effects ; creates light on its position with given properties

  @radius (accessor) - radius of light
  @color (accessor) - color of light
  @luminance (accessor) - strength of light from 1 to 8 ; 8 is solid

  def intialize(x,y,radius,color,luminance)
  
21.Sequence
see: utility&fx.rb 497 to customize and add own actions
Class used to perform scheduled actions. Each next action will take place only if previous one was finished.

  def initialize(sequence)
  sequence - array of actions ; each action is an hash, each requires :type key. The types and their arguments (additional keys) are following:
    :wait - waits given time before next action
      :time (REQUIRED) - number of frames (ticks) to wait
    
    :camera_move - moves camera to given positions
      :target (REQUIRED) - 3 element array: [target_x, target_y, speed]
      
    :camera_follow - follows target
      :target (REQUIRED) - this entity will be followed
      :smooth - if following should be smooth
      
    :flash - makes flash effect
      :values (REQUIRED) - arguments to effect (see: 7.Game.flash)
      
    :shake - makes shake effect
      :values (REQUIRED) - arguments to effect (see: 7.Game.shake
      
    :trail - crates Trail Entity
      :values (REQUIRED) - arguments to constructor (see: 13.Trail)
      
    :trace/:particle - same as :trail
    
    :sample - plays a sound
      :name (REQUIRED) - path/name of the sample
      
    :entity - creates entity of given class
      :class (REQUIRED) - symbol representing name of the class to create
      :values (REQUIRED) - arguments to constructor, depending on class you chose
      
    :fade_in/:fade_out - makes a fade effect
      :effect (REQUIRED) - name of the effect
      :speed (REQUIRED) -speed of the effect
      :mode  - solid mode (see: 7.Game.fade_in/out)
      
  
22.Projectile
see: objects.rb to customize
Template class for projetiles. Includes functions like moving, homing, falling etc. but you have to define yourself how does this interact with other objects

@time - a variable that counts frame lifetime of projectile

def initialize(x,y,type,img,args={})
img - see: Trail
type - :trail, :bullet or :arrow  ;  Defines projectile logic. Types take different hash arguments, some of which are even required
  - :trail - Static animation, useful for explosions ; Takes arguments:
  :animation - array [number of frames, ticks per frame], uses images from img, trails without defined animation will be single-image
  :sequence - define order of frames in animation
  :repeat - number of times to repeat animation or lifetime of single-image
  :movex,:movey - makes trail moving with given speed
  
  - :bullet - Straigh projectile, good for bullets, missiles etc.
  :dir (REQUIRED) - direction of bullet
  :speed - speed of bullet (default is 1)
  :folllow - array [target entity, target offset x, target offset y, bullet offset x, bullet offset y], target will be followed by bullet so (bullets position + offset of bullet) will turn to (target's position + offset of target) ; offset is optional
  :accuracy - ability to turn while following, default is 1
  :limit - limit of following time
  :pointing - bullet image angle will follow dir, pointing is integer which also defines offset of angle
  
  - :arrow - Falling projectile, like arrow or grenade. Make it bouncing yourself
  :vx,:vy (REQUIRED) - starting velocity of arrow
  OR
  :power,:dir (REQUIRED) - used instead of :vx,:vy, just automatically calculates them
  :gravity - default is 1
  :pointing - arrow image angle will follow velocity direction, pointing is integer which also defines offset of angle
  
  type-independent args:
  :angle - angle of projectile's image
  :rotate - angle of projectile changes by this value per frame
  :animation,:sequence - may be used for non-trail projectiles, they won't dissappear like trail
  :z - z-order if different than default
  :scalex,:scaley - scale of image
  :color - color of image
  
  
__________________________________________________________________________________________________________

How to use GUI
- GUI is feature included in game template
- First you need to enable it, by calling  $enable_gui=true
- Then just initialize some GUI objects to use them. It's better to place them in GUI's window. To initialize objects use GUI::ObjName.new
- GUI graphics can be customized in data/GUI. Use only four colors from GUI palette for compatibility

Window
- GUI::Window.new(x,y,width,height,title,customization)
x,y - position of window
width,height - window size
title - window caption
customization - array for options
  example:
  [[:separator,[10,10,50,50]] , [:object,[:button_1,Button.new(20,20,"Press me"]] , [:nox]]
  
  Above you can see 3 types of customization. Each customization is double array: name in symbol and then an array for options.
  - Layout
  You can add texts and separators to your window.
      :separator - [x1, y1, x2, y2]
      :text - [text, x, y]
      
  - Objects
  Add GUI elements. The first option for objects is its name referenced by window, second is new objects insance. They are listed below. Note that objects position is relative to window's
  
  - Additional options
  Window settings, they take no arguments
  :nox - window will have no X for closing
  :disabled - window is invisible at start
  :dock - window is unmovable
  
Windows can be closed and moved. You can only use actve window (the one with foreground border) and to activate window, just click its header, what will automatically move it to top
Windows has also instance variables that can be changed anytime: @nox, @docked, @disabled
You can also retrieve and set values of window's objects by Window.value(object name) and Window.set_value(objects name, value)

GUI Objects
Every objects has its  :value  accessor so values can be easily read and written
They have a   :changed   reader, that returns true if value was changed last frame
They also have a variable  @disabled  that makes them invisible

Button - a bassic button. Read value to check if it's pressed
Arguments: (x, y, text)

Zip - a zip bar with numeric value
Arguments: (x, y, max value, unit)
-unit - pixel distance between values

Check - a simple checkbox
Arguments: (x, y, negateable)
-negateable - check normally takes true or nil, but negateable enables additionally false

Radio - radio-type choice
Arguments: (x, y, choices)
-choices - it's an array of available selections ; it can be modified dynamically

Dropdown - dropdown-box-type choice
Arguments: (x, y, choices)
-choices - it can be modified dynamically

Textbox - a monospaced line of text input
Arguments: (x, y, max)
-max - maximal number of characters

Number - numeric input with textbox
Arguments: (x, y, minimal value, maximal value)
min and max can be modified dynamically

Radio and Dropdown have a   value2   method that returns currently selected text rather than choice id