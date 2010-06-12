require 'rubygems'
require 'graphviz'


# Draw the choices in a bag:
#  in:    choices
#  out:   graph
#
def arrange(choice)
  accumulator = GraphViz.new( :G, :type => :digraph, :path => '/usr/local/bin' )
  accumulator.add_node(choice.name, format(choice))
  add(choice, accumulator)
  accumulator.output( :png => "test.png" )
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
  item_names = choice.item_names
  item_names = (item_names.empty?) ? '(none)' : item_names.join(':')
  {
    'shape' => 'record',
    'label' => "{ #{item_names} | UB: #{choice.upper_bound} | { item | v: #{choice.item_value} | w: #{choice.item_weight} } | { bag | v: #{choice.value} | w: #{choice.weight} } } }"
  }
end