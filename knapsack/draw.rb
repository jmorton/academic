require 'rubygems'
require 'graphviz'


# Draw the choices in a bag:
#  in:    choices
#  out:   graph
#
def draw_bag(choice, filename = 'knapsack.png')
  accumulator = GraphViz.new( :G, :type => :digraph, :path => '/usr/local/bin' )
  accumulator.add_node(choice.name, format(choice))
  add(choice, accumulator)
  accumulator.output( :png => filename )
end

def add(choice, graph)
  accepted = choice.accepted
  declined = choice.declined
  if ! (accepted.nil?)
    ae = graph.add_node(accepted.name, format(accepted))
    graph = add(accepted, graph)
    graph.add_edge(choice.name, ae)
  end
  if ! (declined.nil?)
    de = graph.add_node(declined.name, format(declined))
    graph = add(declined, graph)
    graph.add_edge(choice.name, de)
  end
  graph
end

# Creates a node with labels describing the choice, the value so far,
# and the item.
def format(choice)
  color = node_color(choice)
  item_names = choice.item_names
  item_names = (item_names.empty?) ? '(none)' : item_names.join(':')
  if choice.item
    label = "{ #{item_names} | UB: #{choice.upper_bound} | { #{choice.item_name} | v: #{choice.item_value} | w: #{choice.item_weight} } | { bag | v: #{choice.value} | w: #{choice.weight} } } }"
  else
    label = "{ #{item_names} | UB: #{choice.upper_bound} | { #{choice.item_name} | v: - | w: - } | { bag | v: #{choice.value} | w: #{choice.weight} } } }"
  end
  {
    'shape' => 'Mrecord',
    'label' => label,
    'color' => color,
    'fontcolor' => color
    
  }
end

def node_color(choice)
  case
    when choice.worthless? || choice.overweight?
      color = '#727272'
    else
      color = 'black'
  end
  color
end

# in: pile
# out: graph
def draw_pile(pile, filename)
  graph = GraphViz.new( :G, :type => :digraph, :path => '/usr/local/bin' )
  
  node = graph.add_node('Legend', {
    'shape' => 'Mrecord',
    'label' => "{ Name | { Value | Weight | Density } }"
  })
  
  prior_node = nil
  pile.each do |item|
    node = graph.add_node(item.name, {
      'shape' => 'Mrecord',
      'label' => "{ #{item.name} | { #{item.value } | #{item.weight } | #{item.density} } }"
    })
    graph.add_edge(prior_node, node) if prior_node
    prior_node = node
  end
  graph.output(:png => filename)
end


