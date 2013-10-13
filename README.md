Sapphire (source version) 

The 'source' includes:
- source code (with Template files)
- exe
- icon file
- batch compiler for Windows/Ocra (pretty useless)
- SciTe (Windows)
- this file

Sapphire is:
- stand-alone Ruby for Windows, including gems for making games
- template maker to start developing games with Ruby/Gosu easier


If you are Windows, you can use the exe. If not, you need Ruby and run/compile Sapphire.rb to have same functionality.
And having Ruby installed, the only interesting thing you can do is the !template command (see below). Just run Sapphire.rb
This file describes mainly the Template features.


Specjal commands:
!scite - opens text editor (Windows only)
!template - creates template for game
  You can specify title by typing it after space (!template My_Title)

Template is an empty game project with useful classes to help developing.
__________________________________________________________________________________________________________

Template documentation:

Global variables used:
- $time- global frame counter
- $state - current state of game, which is being updated and drawn
- $screen - window instance
- $enable_gui - set true to enable GUI
- $premusic - used by music prelude


Code files: (number is for class index below)
- (Title).rb  // 1
    Game's core, which loads scripts and has window's class

- specjal.rb  // 2,3,4,5,6
    Major file with helper classes. Manages resources, buttons etc.
    Stop_Music - method that stops any song playing

- game.rb  // 7
    File for main game's state. Manages entities etc.

- utility&fx.rb  // 8,9,10,11,12,13,14,15,16,17,18
    Tools for easy advanced entity control and classes taking care of simple effects, like particles etc. Also some collision classes
    
  objects.rb // 19
    You can put your objects here

- GUI
    Contains GUI module


Classe index (note that there are only some explanations, open files to see constructors etc. Some of them share similar methods so they are not descibed)
1.Main
Window class responsible for updating and drawing game states and reading input.

 def button_down/up(id)
 Checks if specified key is pressed/released. Needs to be placed in state class to work

2.Keypress
Used for input checking, allows to bind keys to symbols

  def Keypress.[](id,repeat)
  id - Gosu::Button or symbol (located in $keys)
  repeat - when false, key is triggered once until releasing it

  def Keypress.Any
  Returns key pressed in current frame (button_down(id))
  
  def Keypress.Define(keys)
  Defines controls (used in main.rb). keys must be a {:symbol=>Gosu::Button} hash
  
  def Keypress.Set(key,new)
  Binds one key, where 'key' is :symbol of key and 'new' is Button to be stored

3.Img \ Snd
Loads specified resoure and saves in memory for re-use

  def .[](name,/tileable/,/pre/)
  name - path to resource
  tileable - used only for Img, true if image has to be tileable
  pre - apply prelude to music. It will be played at the beginning and then the actual music is looped. Prelude must be separate file named '(music_name)-pre'. Using :auto will seek automatically if there's prelude available
  Images need to be .png , music and sound .ogg

4.Tls
Loads tiles from image

  def Tls.[](name,width,height,tileable)
  width/height - size per tile, lower than 0 splits image into width/height tiles

5.Fnt
Loads fonts

  def Fnt.[](name,size)
  name - path to font or name of .ttf file from system's fonts. if specified as Tls array, makes a BitmapFont (see below)
  size - height of the font or array with order of characters for BitmapFont (see below)

6.BitmapFont
Specjal class for custom fonts

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
Main class for game objects.

  @stop (accessor) - prevents entity update
  @invisible (accessor) - skips entity in drawing
  @removed (reader) - entity was removed (see below)
  @spawn_time (reader) - $time value when object was initialized. May be used for counters etc. ($time-@spawn_time is a lifetime value)

  def init(types)
  Pushes entity to game's entity array, so it's being updated. Use types arrray for grouping entities for easier managing

  def remove
  Deletes entity from game's entity array and all group arrays. Note that entity will vanish at the end of update cycle. Calling this sets @removed variatble to true on first

  def gravity(width,height,gravity)
  Method for simple falling physics
  width/height - size of object. When no height is give, it will take width value

7.Game
Default class for handling game action. Manages in-game objects.

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
  Makes simple shake effect by moving screen and creating boundaries
    max - amplitude of oscillation
    time - number of frames between changing position
    num - number of shakes

8.Counter
Object used for countdowns

  @finished (reader) - true if time reaches 0
  @time - current time

  def image(h,m,s,hs)
  Returns string which converts time into hours, minutes, seconds and hundreth of seconds (use variables to specify display)

9.Mover
Basic object to move group of entities together

10.Flasher
Toggles entities' @invisible variable to make them flash effect

  def initialize(entities,time1,time2)
  time1/time2 - how often variable is toggling

11.Delayer
Slows entities' update for certain ammount of frames (see: Flasher)

12.Particle
Simple falling object, may be use eg. for crashing glass

  def initialize(x,y,z,img,vx,vy,args)
  img - path to image or array for tile values (["imagename",w,h,id] instead of Tls method)
  vx/vy - initial speed
  args - hash arguments:
    :angle - initial angle of image (default: 0)
    :rotate - speed of image's rotating
    :scalex/:scaley - objects scale
    :color - color filter for image

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
  speed - speed of fading (max 255)
  args - :angle,:scalex,:scaley,:color (MUST be Gosu::Color)
    :inverted - fades in instead of out

15.Combo
Used for reading key sequences

  @trigger (reader) - changes to true when combo is successful

  def initialize(timeout,sequence)
  timeout - number of frames before combo cancels
  sequence - array of buttons or defined key symbols
  
16.Collision_Box
For bounding box collision detection ; attach it to object

  @w,@h (writer) - size of box
  
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

  @r (writer) - radius of ball
  
  def initialize(x,y,r)
  x,y - coordinates of the center
  r - radius
  
  def collides?(col)
  
  def set(x,y)
  Binds new values for x,y ; use it to follow object box is attached
  
  def move(x,y)
  Adds given values to x,y
  
17.Collision_Group
Group of balls and boxes ; they will move relatively to group position

  @c (reader) - array of colliders attached
  
  def initialize(x,y,a,*c)
  x,y - coordinates of group
  a - angle
  c - array of colliders
  
  def collides?(col)
  Checks if any of attached colliders intersect with col
  
  def set(x,y,a)
  Binds new values for x,y and angle ; children colliders will move accordingly
  
  def move(x,y,a)
  Adds given values to x,y and angle of children colliders
  
18.Projectile
Template class for projetiles. Includes functions like moving, homing, falling etc. but you have to define yourself how does this interact with other objects

Z - constant for default z-order of projectile
@time - a variable that counts frame lifetime of projectile

def initialize(x,y,type,img,args={})
img - look: trail
type - :trail, :bullet or :arrow  ;  Defines projectile logic. Types take different hash arguments, some of which are even required
  - :trail - Static animation, useful for explosions ; Takes arguments:
  :animation - array [number of frames, $time per frame], uses images from img, trails without defined animation will be single-image
  :sequence - define order of frames in animation
  :repeat - number of times to repeat animation or lifetime of single-image
  :movex,:movey - makes trail moving with given speed
  
  - :bullet - Straigh projectile, good for bullets, missiles etc.
  :dir (REQUIRED) - direction of bullet
  :speed - speed of bullet (default is 1)
  :folllow - array [target entity, target offset x, target offset y, bullet offset x, bullet offset y], target will be followed by bullet so offset of bullet will point offset of target
  :accuracy - ability to turn while following, default is 1
  :limit - limit of following time
  :pointing - bullet image angle will follow dir, pointing is integer which also defines offset of angle
  
  - :arrow - Falling projectile, like arrow or grenade. Make it bouncing yourself
  :vx,:vy (REQUIRED) - starting velocity of arrow
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