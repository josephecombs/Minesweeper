require 'json'
require 'yaml'

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
      args = get_input
      over = process_input(args)
      
      over = true if @board.won?  
    end
  end
  
  #player gives input, return true/false if mine has been revealed
  def get_input 
    puts "to save this game, input 's,filename'"
    puts "to load a game, input 'l,filename'"
    puts "input a coordinate to access. prefix with r for reveal or f for flag"
    puts "example 'f,1,2' places a flag at 1,2"
    input = gets.chomp
    
    args = input.split(',')
  end
  
  def process_input(args)
    if args[0] == "f" || args[0] == "r"
      chosen_tile = @board.board[Integer(args[1])][Integer(args[2])]
    end
    if args[0] == 'r'
      if chosen_tile.has_mine
        puts "You clicked on a mine!"
        return true
      end
      chosen_tile.reveal(@board.board)
    elsif args[0] == 'f'
      chosen_tile.flagged = true
    elsif args[0] == 's'
      save_state = @board.to_yaml
      f = File.open(args[1], 'w')
      f.write(save_state)
    elsif args[0] == 'l'
      @board = YAML::load(File.read(args[1]))
      
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
        @board[i][j].neighbors = bestow_neighbors(i, j, @dim)        
      end
    end
  end
  
  def bestow_neighbors(i, j, dim)
    neighbor_coordinates = NEIGHBOR_OFFSETS.map do |coord|
      [i + coord[0], j + coord[1]]
    end
    
    neighbor_coordinates.map! do |coord2|
      (0...dim).cover?(coord2[0]) && (0...dim).cover?(coord2[1]) ? coord2 : nil
    end

    neighbor_coordinates.compact
  end
  
  # def set_neighbors(board, dim)
#     #iterate through all neighbors on the board and put them in an array
#     neighbor_coordinates = NEIGHBOR_OFFSETS.map do |coord|
#       [@coordinates[0] + coord[0], @coordinates[1] + coord[1]]
#     end
#
#     neighbor_coordinates.each do |coord2|
#       coord2 = nil unless (0...dim).cover?(coord2[0]) && (0...dim).cover?(coord2[1])
#     end
#
#     neighbor_coordinates.compact
#   end
  
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
    true_print_grid = []
    
    grid = Array.new(@dim) { Array.new(@dim, "_") }
    @board.each_with_index do |row, i|
      row.each_with_index do |tile, j|
        grid[i][j] = tile.display_masked_state
      end
      true_print_grid << grid[i].join
    end
    true_print_grid.reverse!
    
    true_print_grid.each do |line|
      puts line
    end
  end
  
  def won?
    #board will be won when masked state matches full state with flags replacing
    #mines OR all non mine tiles have been revealed
    
    
  end
end

class Tile
  attr_reader :revealed, :has_mine
  attr_accessor :neighbor_mine_count, :flagged, :coordinates, :neighbors
  
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
  
  def reveal(board)
    return if @revealed
    @revealed = true
    #if a mine, return
    
    
    # iterate through neighbors
    #  if there is a mine or a flag, don't reveal. else reveal
    # 
    #neighbor_coordinates = neighbors(board, dim)
    
    if @neighbor_mine_count > 0 || @has_mine
      return
    end
    
    # if (cur_neighbor_tile.has_mine || cur_neighbor_tile.flagged)
#       return board
#     else
    p @neighbors
    @neighbors.each do |neighbor|
      cur_neighbor_tile = board[neighbor[0]][neighbor[1]]
      cur_neighbor_tile.reveal(board)
    end

  end
  
  def display_masked_state
    return "F" if @flagged == true
    return self.neighbor_mine_count if @revealed
    
    "_"
  end
  
end

a = Game.new(1, 4)
a.play_game

# b = Board.new(5, 4)
#
# `b.get_full_state
# p b.get_masked_state