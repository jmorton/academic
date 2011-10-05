require 'knapsack.rb'
require 'draw.rb'

# Takes a list of items, sorts them
def process(items, draw_each_step = false)
  # Put the most dense items at the top of the pile.
  sorted_pile = items.sort do |item1,item2|
    item2.density <=> item1.density
  end

  # Add each item to the bag
  bag = Knapsack::Bag.new(10, sorted_pile)
  sorted_pile.each_with_index do |item, ix|
    bag.consider(item)
    if draw_each_step
      Knapsack::draw_bag(bag.start, "tree-#{ix}.png")
    end
  end

  # Draw a picture...
  Knapsack::draw_bag(bag.start, "tree.png")
  Knapsack::draw_pile(sorted_pile, "pile.png")
end

items = [
  Knapsack::Item.new(4, 40, "Sand"),
  Knapsack::Item.new(7, 42, "Gold"),
  Knapsack::Item.new(5, 25, "Water"),
  Knapsack::Item.new(3, 12, "Beer"),
  Knapsack::Item.new(2, 1,  "Iron"),
  Knapsack::Item.new(6, 15, "Scotch"),
]

process(items, false)