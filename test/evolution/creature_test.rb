require File.join(File.dirname(__FILE__), "/../test_helper")


class CreatureTest < Test::Unit::TestCase

  context 'initialization' do
    
    setup { @creature = Evolution::Creature.new }
    
    should 'initialize with one polygon' do
      @creature.polygons.size.should == 1
    end
    
    should 'increment id by 1 for each new instance' do
      @creature.id.should == 1
      Evolution::Creature.new.id.should == 2
    end
    
  end
  
  context 'mutating' do
    
    setup { @creature = Evolution::Creature.new }
    
    context 'adding a new polygon' do
      
      setup do
        mock(@creature).rand(Evolution::ADD_POLYGON_MUTATION_RATE) { 0 }
        mock.proxy(@creature).add_polygon
        @creature.mutate
      end
      
      should_change('the number of polygons', :by => 1) { @creature.polygons.size }
      
    end
    
    context 'mutating existing polygons' do
      
      setup do
        mock.proxy(@creature).mutate_polygons
      end
      
      should 'mutate all existing polygons' do
        @creature.polygons.each { |polygon| mock.proxy(polygon).mutate }
        @creature.mutate
      end
      
    end
        
  end
  
  context 'spawning a child' do
    
    should 'dup each polygon'
    
  end

end