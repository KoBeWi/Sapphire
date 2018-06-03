str=$0.split('/')
str.pop
$path=str.join('/')
$path=$path+(if $path != '' then '/' else Dir.getwd+'/' end)

puts "-"*37
puts "Ruby #{RUBY_VERSION}"
require 'gosu'
include Gosu
puts "Gosu #{Gosu::VERSION}"
require 'ashton'
puts "Ashton #{Ashton::VERSION}"
require 'chipmunk'
puts "Chipmunk 6.1.3.4"
require 'fileutils'

begin
rq=if ARGV[0] then ARGV[0] else puts "-"*37 ; puts "Type program to run (or !help):"
Dir.getwd+'/'+gets.chomp end
puts "-"*37
if rq.split[0]==Dir.getwd+'/'+'!scite'
  `#{$path}scite/scite.exe`
elsif rq.split[0]==Dir.getwd+'/'+'!help'
  `notepad #{$path}README.md`
elsif rq.split[0]==Dir.getwd+'/'+'!examples'
  FileUtils.cp($path+'Examples.zip',Dir.getwd)
elsif rq.split[0]==Dir.getwd+'/'+'!template'
  name='Template' ; name=rq.split(' ')[1] if rq.split(' ')[1]
  Dir.mkdir("#{name}")
  Dir.mkdir("#{name}/data")
  Dir.mkdir("#{name}/data/scripts")
  Dir.mkdir("#{name}/data/gfx")
  Dir.mkdir("#{name}/data/sfx")
  Dir.mkdir("#{name}/data/music")
  Dir.mkdir("#{name}/data/core")
  Dir.mkdir("#{name}/data/core/GUI")
  Dir.mkdir("#{name}/data/fades")
  
  f1=File.new(name+'/'+name+'.rb','w')
  f2=File.open($path+"data/main.rb",'r')
  f1.puts(f2.readlines.join)
  f1.close ; f2.close
  
  f1=File.new(name+'/data/core/'+'core.rb','w')
  f2=File.open($path+'data/core/core.rb','r')
  f1.puts(f2.readlines.join)
  f1.close ; f2.close
  
  f1=File.new(name+'/data/scripts/'+'system.rb','w')
  f2=File.open($path+'data/system.rb','r')
  f1.puts(f2.readlines.join)
  f1.close ; f2.close
  
  f1=File.new(name+'/data/scripts/'+'GUI.rb','w')
  f2=File.open($path+'data/GUI.rb','r')
  f1.puts(f2.readlines.join)
  f1.close ; f2.close
  
  f1=File.new(name+'/data/scripts/'+'utility.rb','w')
  f2=File.open($path+'data/utility.rb','r')
  f1.puts(f2.readlines.join)
  f1.close ; f2.close
  
  f1=File.new(name+'/data/scripts/'+'fx.rb','w')
  f2=File.open($path+'data/fx.rb','r')
  f1.puts(f2.readlines.join)
  f1.close ; f2.close
  
  f1=File.new(name+'/data/scripts/'+'game.rb','w')
  f2=File.open($path+'data/game.rb','r')
  f1.puts(f2.readlines.join)
  f1.close ; f2.close
  
  f1=File.new(name+'/data/scripts/'+'objects.rb','w')
  f2=File.open($path+'data/objects.rb','r')
  f1.puts(f2.readlines.join)
  f1.close ; f2.close
  
  ['GUI/Close.png','GUI/Cursor.png','GUI/Radio.png','Dark.png','Light.png','fader.frag','light.frag'].each{|img| FileUtils.cp($path+'data/core/'+img,name+'/data/core/'+img)}
  
  puts 'Template created'
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