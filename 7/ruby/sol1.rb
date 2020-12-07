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
  splitted = line.split(" bags contain ")
  parent = splitted[0]
  parent_node = get_node(parent)

  splitted[1].split(", ").each do |str|
    if str != "no other bags." then
      splitted = str.split(" ")
      qty = splitted[0].to_i
      child = splitted[1..2].join(" ")
      child_node = get_node(child)

      child_node[:parents].append(parent_node)
      parent_node[:children][child] = {
        :id => child,
        :qty => qty,
        :node => child_node
      }
    end
  end
end

def find_parents(arr, child)
  parents = get_node(child)[:parents]

  parents.each do |parent|
    arr.append(parent[:id])
    find_parents(arr, parent[:id])
  end

  return arr
end

def count_children(parent)
  children = get_node(parent)[:children]

  total = 0

  children.each do |_, child|
    total += child[:qty]
    total += child[:qty] * count_children(child[:id])
  end

  return total
end

puts find_parents([], "shiny gold").uniq!.length
puts count_children("shiny gold")
