require 'byebug'

class MazeLocation
  attr_reader :position, :parent_position, :g_value, :f_value

  def initialize(position, parent_position, g_value, f_value)
    @position = position
    @parent_position = parent_position
    @g_value = g_value
    @f_value = f_value
  end

end

def [](pos)
  @maze[pos[0]][pos[1]]
end

def []=(pos, mark)
  @maze[pos[0]][pos[1]] = mark
end

def run_maze
  setup
  walk_maze until @current.position == @finish_position
  show_path(get_path)
end

def setup
  import_maze
  find_start_and_end
  scan_first_step
end

def import_maze
  @maze = []
  File.open(ARGV[0]).each_line do |line|
   @maze << line.chomp.chars
  end
end

def find_start_and_end
  @start_position = get_location("S")
  @finish_position = get_location("E")
end

def scan_first_step
  @closed_list = [MazeLocation.new(@start_position, nil, 0, nil)]
  @open_list = []
  @current = @closed_list.first
  scan(@current.position)
end

def get_location(letter)
  row = @maze[0].length
  flat_maze = @maze.flatten.index(letter)
  [flat_maze/row, flat_maze%row]
end

def walk_maze
  next_stop = @open_list.shift
  @closed_list << next_stop
  @current = next_stop
  scan(@current.position)
end

def scan(pos)
  adjacent_positions(pos).each do |adjacent|
    scan_adjacent(adjacent)
  end
  @open_list.sort! { |x,y| x.f_value <=> y.f_value }
end

def adjacent_positions(pos)
  x = pos[0]
  y = pos[1]
  [[x, y + 1], [x, y - 1], [x + 1, y], [x - 1, y]]
end

def scan_adjacent(pos)
  if can_be_added?(pos)
    @open_list << MazeLocation.new(pos, @current.position,
                                   @current.g_value + 1, f_value(pos))
  end
end

def h_value(pos)
  (pos[0] - @finish_position[0]).abs + (pos[1] - @finish_position[1]).abs
end

def f_value(pos)
   h_value(pos) + @current.g_value + 1
end

def can_be_added?(pos)
  # debugger
  if self[pos] == "*" ||
     @open_list.any? { |x| x.position == pos } ||
     @closed_list.any? { |x| x.position == pos }
    return false
  end
  true
end

def get_path
  # debugger
  backtrack = @closed_list.last.position
  path = [backtrack]
  until backtrack == @start_position
    backtrack_next = @closed_list.index { |x| x.position == backtrack }
    backtrack = @closed_list[backtrack_next].parent_position
    path << backtrack
  end
  path
end

def show_path(path)
  path.each do |pos|
    self[pos] = "X" unless self[pos] == "S"
  end

  @maze.each { |line| puts line.join}
end

run_maze
