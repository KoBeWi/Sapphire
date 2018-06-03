str=$0.split('/')
str.pop
$path=str.join('/')
$path=$path+(if $path != '' then '/' else Dir.getwd+'/' end)

rq = ARGV[0]
if !rq
  puts "_" * 40
  puts "Ruby #{RUBY_VERSION}"
  require 'gosu'
  include Gosu
  puts "Gosu #{Gosu::VERSION}"
  require 'opengl'
  puts "OpenGL 0.10.0"
  require 'ashton'
  puts "Ashton #{Ashton::VERSION}"
  require 'chipmunk'
  puts "Chipmunk 6.1.3.4"
  require 'fileutils'
  
  print "_" * 40 + "\nSpecify program to run: "
  rq = Dir.getwd + '/' + gets.chomp
  puts "_" * 40
else
  require 'gosu'
  include Gosu
  require 'opengl'
  require 'ashton'
  require 'chipmunk'
  require 'fileutils'
end

begin

require rq

rescue Exception => e
  if e
    puts "_"*40
    puts 'An error has occured:'
    puts e
    puts e.backtrace
    $screen.close if $screen
    puts "_"*40
    gets
  end
end