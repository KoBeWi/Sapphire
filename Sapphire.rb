str=$0.split('/')
str.pop
$path=str.join('/')
$path=$path+(if $path != '' then '/' else Dir.getwd+'/' end)

puts "-"*37
puts "Ruby 1.9.2"
require 'gosu'
include Gosu
puts "Gosu #{Gosu::VERSION}"
require 'ashton'
puts "Ashton 0.0.3alpha"
require 'texplay'
puts "Texplay #{TexPlay::VERSION}"
include Gl
include Glu
puts "Opengl-0.8.0.pre1"
require 'fileutils'

class Code_Requiristier
rq=if ARGV[0] then ARGV[0] else puts "-"*37 ; puts "Type program to run (or !help):"
Dir.getwd+'/'+gets.chomp end
puts "-"*37
if rq.split[0]==Dir.getwd+'/'+'!scite'
  `#{$path}scite/scite.exe`
elsif rq.split[0]==Dir.getwd+'/'+'!help'
  `notepad #{$path}README`
elsif rq.split[0]==Dir.getwd+'/'+'!template'
  name='Template' ; name=rq.split(' ')[1] if rq.split(' ')[1] and rq.split(' ')[1] != '!require'
  Dir.mkdir("#{name}")
  Dir.mkdir("#{name}/data")
  Dir.mkdir("#{name}/data/scripts")
  Dir.mkdir("#{name}/data/gfx")
  Dir.mkdir("#{name}/data/sfx")
  Dir.mkdir("#{name}/data/music")
  Dir.mkdir("#{name}/data/GUI")
  
  f1=File.new(name+'/'+name+'.rb','w')
  f2=File.open($path+"data/main.rb",'r')
  f1.puts(f2.readlines.join)
  f1.close ; f2.close
  
  f1=File.new(name+'/data/scripts/'+'specjal.rb','w')
  f2=File.open($path+'data/specjal.rb','r')
  f1.puts(f2.readlines.join)
  f1.close ; f2.close
  
  f1=File.new(name+'/data/scripts/'+'utility&fx.rb','w')
  f2=File.open($path+'data/utility&fx.rb','r')
  f1.puts(f2.readlines.join)
  f1.close ; f2.close
  
  f1=File.new(name+'/data/scripts/'+'game.rb','w')
  f2=File.open($path+'data/game.rb','r')
  f1.puts(f2.readlines.join)
  f1.close ; f2.close
  
  f1=File.new(name+'/data/scripts/'+'GUI.rb','w')
  f2=File.open($path+'data/GUI.rb','r')
  f1.puts(f2.readlines.join)
  f1.close ; f2.close
  
  f1=File.new(name+'/data/scripts/'+'objects.rb','w')
  f1.close
  
  ['Check.png','Close.png','Cursor.png','Dropdown.png','Radio.png','Zip.png'].each{|img| FileUtils.cp($path+'data/GUI/'+img,name+'/data/GUI/'+img)}
  
  puts 'Szablon utworzony'
  gets
else
    ARGV.clear
    require rq
end
rescue Exception => e
  if e
    puts "_"*37
    puts 'Error found:'
    puts e
    puts e.backtrace
    $screen.close if $screen
    puts "_"*37
    gets
  end
end
#Code_Requiristier.new