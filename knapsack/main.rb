load 'knapsack.rb'
load 'draw.rb'

original_pile = [
  Item.new(4, 40, "A"),
  Item.new(7, 42, "B"),
  Item.new(5, 25, "C"),
  Item.new(3, 12, "D"),
]

# Put the most dense items at the top of the pile.
sorted_pile = original_pile.sort do |item1,item2|
  item2.density <=> item1.density
end

# Add each item to the bag
bag = Bag.new(10, sorted_pile)

sorted_pile.each do |item|
  bag.consider(item)
end

# Draw a picture...
ns = bag.choices.sort { |n1,n2| n1.value <=> n2.value }
arrange(bag.start)
