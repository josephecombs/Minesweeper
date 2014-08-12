class Game
  
  def initialize(num_mines, dim)
    @board = Board.new(num_mines, dim)
  end
  
  def play_game
    #initialize board  
    
    over = false
    until over
      puts "Board state:"
      @board.get_masked_state
      p @board
      gets.chomp
      args = get_input
      over = process_input(args)
      
      over = true if @board.won?  
    end
  end
  
  #player gives input, return true/false if mine has been revealed
  def get_input 
    puts "input a coordinate to access. prefix with r for reveal or f for flag"
    puts "example 'f,1,2' places a flag at 1,2"
    input = gets.chomp
    
    args = input.split(',')
  end
  
  def process_input(args)
    if args[0] == 'r'
      chosen_tile = @board.board[Integer(args[1])][Integer(args[2])]
      
      if chosen_tile.has_mine
        puts "You clicked on a mine!"
        return true
      end
      
      
      @board.board = chosen_tile.reveal(@board.board, @board.dim)
      #should return coordinates of tiles that are now revealed
      
    elsif args[0] == 'f'
      #flag the coordinate
    else
      puts "incorrect input"
    end
    false
  end
  
  
end

class Board
  attr_reader :dim
  attr_accessor :board
  
  def initialize(num_mines, dim)
    @dim = dim
    @board = create_random_board(num_mines)
    bestow_coordinates
    paint_all_neighbors
    bestow_neighbors
  end

  def create_random_board(num_mines)
    seed_board_array = Array.new(@dim ** 2, false)
    num_mines.times { |i| seed_board_array[i] = true }
    seed_board_array.shuffle!
    
    
    board_grid = Array.new(@dim) { Array.new(@dim) do |array_space|
      Tile.new(seed_board_array.pop)
    end }

  end
  
  def bestow_coordinates
    @dim.times do |i|
      @dim.times do |j|
        @board[i][j].coordinates = [i, j]
      end
    end
  end
  
  def bestow_neighbors
    @dim.times do |i|
      @dim.times do |j|
        @board[i][j].set_neighbors(@board, @dim)
      end
    end
  end
  
  NEIGHBOR_OFFSETS = [
    [-1, -1],
    [ 0, -1],
    [ 1, -1],
    [ 1,  0],
    [ 1,  1],
    [ 0,  1],
    [-1,  1],
    [-1,  0]
  ]
  
  def paint_all_neighbors
    @board.each_with_index do |row, i|
      row.each_with_index do |tile, j|

        neighbor_coordinates = Array.new(8)
        
        neighbor_coordinates = NEIGHBOR_OFFSETS.map do |offset|
          [offset[0] + i, offset[1] + j]
        end
        
        neighbor_mine_count = 0

        neighbor_coordinates.each do |coord|
          if (0...@dim).cover?(coord[0]) && (0...@dim).cover?(coord[1])
            if @board[coord[0]][coord[1]].has_mine 
              neighbor_mine_count += 1
            end
          else
            #off board
          end
        end
        
        tile.neighbor_mine_count = neighbor_mine_count    
      end
    end
  end
    
  def get_full_state
    @board
  end
  
  def get_masked_state
    grid = Array.new(@dim) { Array.new(@dim, "_") }
    @board.each_with_index do |row, i|
      row.each_with_index do |tile, j|
        grid[i][j] = tile.display_masked_state
      end
      puts grid[i].join
    end
  end
  
  def won?
    #board will be won when masked state matches full state with flags replacing
    #mines OR all non mine tiles have been revealed
    
    
  end
end

class Tile
  attr_reader :revealed, :has_mine
  attr_accessor :neighbor_mine_count, :flagged, :coordinates
  
  def initialize(has_mine)
    @has_mine = has_mine
    @revealed = false
    @neighbor_mine_count = 0
    @flagged = false
    @neighbors = Array.new(8)
    @coordinates = [-99, -99]
  end
  
  def set_mine(bool)
    @has_mine = bool
  end
  
  def reveal(board, dim)
    @revealed = true
    #if a mine, return
    local_board = board.dup
    #if @neighbor_mine_count == 0
    # iterate through neighbors
    #  if there is a mine or a flag, don't reveal. else reveal
    # 
    #neighbor_coordinates = neighbors(local_board, dim)
    @neighbors.each do |neighbor|
      cur_neighbor_tile = local_board[neighbor[0]][neighbor[1]]
      if !(cur_neighbor_tile.has_mine || cur_neighbor_tile.flagged)
        cur_neighbor_tile.reveal(local_board, dim)
      end
    end
    
    local_board
  end
  
  def display_masked_state

    return self.neighbor_mine_count if @revealed
    "_"
    

  end
  
  NEIGHBOR_OFFSETS = [
    [-1, -1],
    [ 0, -1],
    [ 1, -1],
    [ 1,  0],
    [ 1,  1],
    [ 0,  1],
    [-1,  1],
    [-1,  0]
  ]

  def set_neighbors(board, dim)
    #iterate through all neighbors on the board and put them in an array
    neighbor_coordinates = NEIGHBOR_OFFSETS.map do |coord|
      [@coordinates[0] + coord[0], @coordinates[1] + coord[1]]
    end
    
    neighbor_coordinates.each do |coord2|
      coord2 = nil unless (0...dim).cover?(coord2[0]) && (0...dim).cover?(coord2[1])
    end
    
    neighbor_coordinates.compact
  end
  
  #create a mine count by iterating through the neighbors array
  
end

a = Game.new(8, 4)
a.play_game

# b = Board.new(5, 4)
#
# `b.get_full_state
# p b.get_masked_state