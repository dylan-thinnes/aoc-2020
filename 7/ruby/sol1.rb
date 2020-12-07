$dict = {}

def get_node(id)
  if not $dict[id] then
    $dict[id] = {
      :id => id,
      :children => {},
      :parents => []
    }
  end

  return $dict[id]
end

STDIN.read.split("\n").each do |line|
  parent, *children = line.split(/ bags contain no other bags\.| bags contain | bags?, | bags\./)
  parent_node = get_node parent

  children.each do |str|
    match = str.match(/(?<qty>\d+) (?<id>\w+ \w+)/)
    child_node = get_node match[:id]

    child_node[:parents].append parent_node
    parent_node[:children][match[:id]] = {
      :id => match[:id],
      :qty => match[:qty].to_i,
      :node => child_node
    }
  end
end

def find_parents(child_id)
  def helper(arr, child)
    parents = child[:parents]

    parents.each do |parent|
      arr.append parent[:id]
      helper arr, parent
    end

    return arr
  end

  return helper([], get_node(child_id)).uniq!.length
end

def count_children(parent)
  def helper(parent)
    children = parent[:children]

    total = 0

    children.each do |_, child|
      total += child[:qty]
      total += child[:qty] * helper(child[:node])
    end

    return total
  end

  return helper get_node "shiny gold"
end

puts find_parents "shiny gold"
puts count_children "shiny gold"
