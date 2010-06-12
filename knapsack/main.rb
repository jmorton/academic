load 'knapsack.rb'
load 'draw.rb'

# Takes a list of items, sorts them
def process(items, draw_each_step = false)
  # Put the most dense items at the top of the pile.
  sorted_pile = items.sort do |item1,item2|
    item2.density <=> item1.density
  end

  # Add each item to the bag
  bag = Bag.new(10, sorted_pile)
  sorted_pile.each_with_index do |item, ix|
    bag.consider(item)
    if draw_each_step
      draw_bag(bag.start, "tree-#{ix}.png")
    end
  end

  # Draw a picture...
  ns = bag.best
  draw_bag(bag.start, "tree.png")
  draw_pile(sorted_pile, "pile.png")
end

items = [
  Item.new(4, 40, "A"),
  Item.new(7, 42, "B"),
  Item.new(5, 25, "C"),
  Item.new(3, 12, "D"),
  Item.new(2, 1,  "E"),
  Item.new(6, 15, "F"),
  Item.new(1, 9,  "G"),
  Item.new(8, 23, "H"),
]

process(items, true)