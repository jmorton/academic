load 'draw.rb'

class Item
  
  attr_accessor :weight, :value, :name
  
  def initialize(weight, value, name = '?')
    self.weight, self.value, self.name = weight, value, name
  end
  
  def density
    self.value.to_f / self.weight.to_f
  end
  
  def to_s
    name
  end
  
end

class Bag
  
  attr_accessor :capacity, :start, :choices
  
  def initialize(capacity = 10, pile = nil)
    # The root of the tree contains no items, we assume the pile is
    # already sorted.  Each choice knows about the bag and pile
    # so that it can calculate the upper bound.
    self.start = Choice.new(nil, nil, self, pile)
        
    # All of the choices made along the way are added to a list
    # so that the best choices can be selected without traversing
    # the tree of choices.
    self.choices = [ self.start ]
    
    # Capacity refers to the total weight of items that can fit
    # into the bag.
    self.capacity = capacity
  end
  
  # Evaluate an item for inclusion in the bag.  For all of the best choices
  # This will create two different choices: one having accepted the item for
  # inclusion, the other declining it.
  def consider(item)
    # Call map! so that the underlying choice is updated
    # otherwise a copy of each choice will be used and the
    # accepted/declined attribute will not be updated.
    new_choices = self.choices.map! do |some_choice|
      unless some_choice.hopeless? or some_choice.overweight?
        some_choice.consider(item)
      end
    end
    self.choices += new_choices
    self.choices.flatten!.compact!
  end
  
end

class Choice

  attr_accessor :bag, :pile, :item, :parent, :accepted, :declined
  
  def initialize(item, parent, bag, pile)
    self.item, self.parent, self.bag, self.pile = item, parent, bag, pile
  end
  
  # Take an item, and create two choices – one where the item is
  # assigned and another where the item is not.
  def consider(item)
    self.accepted = Choice.new(item, self, self.bag, self.pile)
    self.declined = Choice.new(nil, self, self.bag, self.pile)
    return [self.accepted, self.declined]
  end
  
  def upper_bound
    item_value + (next_item_density * remaining_capacity)
  end
  
  def next_item_density
    pile.first && pile.first.density || 0
  end
  
  def remaining_capacity
    bag.capacity - (item_weight + parent_weight)
  end
  
  def hopeless?
    upper_bound <= 0
  end
  
  def overweight?
    remaining_capacity < 0
  end
  
  def weight
    item_weight + parent_weight
  end
  
  def value
    item_value + parent_value
  end
    
  def item_weight
    item && item.weight || 0
  end
  
  def item_value
    item && item.value || 0
  end
  
  def item_name
    item && item.name || "(none)"
  end
  
  def parent_weight
    parent && parent.weight || 0
  end

  def parent_value
    parent && parent.item_value || 0
  end
  
  def ancestors
    if self.parent.nil?
      return []
    else
      [self] + self.parent.ancestors
    end
  end
  
  def ancestor_items
    ancestors.map { |a| a.item }.compact
  end
  
  def item_names
    (ancestor_items).compact.map { |i| i.name }
  end
  
  def ancestor_names
    ancestors.map { |a| a.name }
  end
  
  def to_s
    "value: #{value}\t weight: #{weight}\t bound: #{upper_bound}\t items: #{item_names}"
  end
  
  def name
    "#{ancestors.length}:#{ancestor_items.length}:#{item_names.join(':')}"
  end
  
  def match(n)
    n == self
  end  
    
end

