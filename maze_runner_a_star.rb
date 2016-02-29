require 'byebug'
# [location, g-value, f-value, parent]
@open_list  = []
# [location, g-value, f-value, parent]
@closed_list  = []
@start = []
@finish = []
@g = 0
@current = []
@done  = false

def [](pos)
  @maze[pos[0]][pos[1]]
end

def []=(pos, mark)
  @maze[pos[0]][pos[1]] = mark
end

def import_maze
  maze = []
  File.open(ARGV[0]).each_line do |line|
   maze << line.chomp.chars
  end
  maze
end

def setup
  @maze = import_maze
  @start = get_position("S")
  @finish = get_position("E")
  @current = @start
  @closed_list << [@start, 0]
  scan(@start)
end

def get_position(letter)
  pos = @maze.flatten.index(letter)
  [pos/(@maze[0].length), pos%(@maze[0].length)]
end

def run_maze
  setup
  iterate until @current == @finish
  show_path(get_path)
end

def iterate
  next_stop = @open_list.shift
  @closed_list << next_stop
  @current = next_stop[0]
  @g = next_stop[1]
  scan(@current)
end

def scan(pos)
  x = pos[0]
  y = pos[1]

  process([x, y + 1])
  process([x, y - 1])
  process([x + 1, y])
  process([x - 1, y])

  @open_list.sort! { |x,y| x[2] <=> y[2] }
end

def process(pos)
  if can_be_added?(pos)
    @open_list << [pos, @g + 1, f_value(pos), @current]
  end
end

def f_value(pos)
  (pos[0] - @finish[0]).abs + (pos[1] - @finish[1]).abs + @g + 1
end

def can_be_added?(pos)
  value = true
  value = false if self[pos] == "*"
  value = false if @open_list.any? { |x| x[0] == pos }
  value = false if @closed_list.any? { |x| x[0] == pos }
  value
end

def get_path
  pos = @closed_list.last.last
  path = [pos]
  until pos == @start
    pos_next = @closed_list.index { |x| x[0] == pos }
    pos = @closed_list[pos_next][3]
    path << pos
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
