# this version of the algorithm uses a sort of gradient descent on the newest polygon instead of
# a straight hill-climb algorithm like evolution.rb

require 'rubygems'
require 'rvg/rvg'
require 'fileutils.rb'
include Magick

RENDER_PATH = "/Users/username/Sites/evolution"
BASELINE_IMAGE_PATH = "/Users/username/Sites/evolution/baseline-200.gif"
BASELINE_IMAGE = Magick::Image.read(BASELINE_IMAGE_PATH)
CANVAS_SIZE = 200 # square which should match baseline image size
CANVAS_BACKGROUND = "red"

LEARNING_RATE = 10
MIN_ALPHA = 20

$id = 0
$bump = 0

class Array
  
  def random(weights = nil)
    return random(map {|n| n.send(weights)}) if weights.is_a? Symbol

    weights ||= Array.new(length, 1.0)
    total = weights.inject(0.0) {|t,w| t+w}
    point = rand * total

    zip(weights).each do |n,w|
      return n if w >= point
      point -= w
    end
  end
  
end

class Creature
  
  attr_accessor :creature_id, :fitness, :image, :image_path, :polygons
  
  def initialize
    @creature_id = next_id
  end
  
  def image
    @image ||= RVG.new(CANVAS_SIZE, CANVAS_SIZE).viewbox(0,0,CANVAS_SIZE,CANVAS_SIZE){ |canvas|
                 canvas.background_fill = CANVAS_BACKGROUND
                 self.polygons.each{ |polygon| canvas.polygon(polygon[:points].flatten).styles(:fill=> generate_fill_string(polygon)) }
               }.draw
  end
  
  def save
    @image.write(self.image_path)
  end

  def fitness
    @fitness ||= self.image.difference(BASELINE_IMAGE[0])[0]
  end
  
  def image_path
    @image_path ||= "#{RENDER_PATH}/#{"%09i" % creature_id}.gif" 
  end
  
  def spawn_best_child
    array = []
    x = [LEARNING_RATE, LEARNING_RATE * -1]
    x.each{|a| x.each{|b| x.each{|c| x.each{|d| x.each{|e| x.each{|f| x.each{|g| x.each{|h| x.each{|i| x.each{|j| array << [a,b,c,d,e,f,g,h,i,j] } } } } } } } } } }
    
    possibilities = array.map{ |a|
      child = Creature.new
      child.polygons = eval(@polygons.inspect)
      last = child.polygons.last
      new_p = { :blue => last[:blue] + a[0],
                              :alpha => last[:alpha] + a[1], 
                              :red => last[:red] + a[2],
                              :green => last[:green] + a[3],
                              :points=>[[last[:points][0][0] + a[4], last[:points][0][1] + a[5]],
                                        [last[:points][1][0] + a[6], last[:points][1][1] + a[7]],
                                        [last[:points][2][0] + a[8], last[:points][2][1] + a[9]]]}
      new_p[:alpha] = MIN_ALPHA if new_p[:alpha] < MIN_ALPHA
      child.polygons = child.polygons.size == 1 ? [] : child.polygons[0..child.polygons.size-2]
      child.polygons << new_p
      child
    }
    return possibilities.sort_by{|c| c.fitness}.first
  end
  
end

def next_id
  $id += 1
end

def generate_fill_string(polygon)
  "#" + to_hex(polygon[:red]) + to_hex(polygon[:green]) + to_hex(polygon[:blue]) + to_hex(polygon[:alpha])
end

def to_hex(integer)
  integer.to_s(base=16).rjust(2, '0')
end

def random_new_polygon
  points = []
  hexes = []
  point_offset_x = rand(CANVAS_SIZE)
  point_offset_y = rand(CANVAS_SIZE)
  
  3.times do
    x = point_offset_x + rand(CANVAS_SIZE / 10)
    x = 0 if x < 0
    x = CANVAS_SIZE if x > CANVAS_SIZE
    points << x
    
    y = point_offset_y + rand(CANVAS_SIZE / 10)
    y = 0 if y < 0
    y = CANVAS_SIZE if y > CANVAS_SIZE
    points << y
  end

  4.times { hexes << rand(256) }

  {:points => [[points.pop,points.pop], [points.pop,points.pop], [points.pop,points.pop]], :red => hexes.pop, :green => hexes.pop, :blue => hexes.pop, :alpha => hexes.pop}
end

@most_fit = Creature.new
@most_fit.polygons = [random_new_polygon]

while $id < 1000000
  child = @most_fit.spawn_best_child
  
  if child.fitness < @most_fit.fitness
    child.save if ($bump += 1) % 2 == 0
    puts "fitness: #{child.fitness.to_s[0..7]} -- polygon count: #{child.polygons.size.to_s}"
    @most_fit = child
  else
    puts "adding polygon"
    child.polygons << random_new_polygon
    @most_fit = Creature.new
    @most_fit.polygons = child.polygons 
  end
end