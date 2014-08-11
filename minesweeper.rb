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
      over = get_input
      
      over = true if @board.won?  
    end
  end
  
  #player gives input, return true/false if mine has been revealed
  def get_input 
    puts "input a coordinate to access. prefix with r for reveal or f for flag"
    puts "example 'f,1,2' places a flag at 1,2"
    input = gets.chomp
    
    args = input.split(',')
    p Integer(args[1])
    p Integer(args[2])
    if args[0] == 'r'
      chosen_tile = @board.board[Integer(args[1])][Integer(args[2])]
      chosen_tile.reveal
      #if its a mine, game over
      if chosen_tile.has_mine
        puts "You clicked on a mine!"
        return true
      end
    elsif args[0] == 'f'
      #flag the coordinate
    else
      puts "incorrect input"
    end
    false
  end
  
  #change masked state
  
  
end

class Board
  attr_reader :board
  
  def initialize(num_mines, dim)
    @dim = dim
    @board = create_random_board(num_mines)
  end
  
  def create_random_board(num_mines)
    seed_board_array = Array.new(@dim ** 2, false)
    num_mines.times { |i| seed_board_array[i] = true }
    seed_board_array.shuffle!
    
    board_grid = Array.new(@dim) { Array.new(@dim) { Tile.new(seed_board_array.pop) }}
    
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
  
  def initialize(has_mine)
    @has_mine = has_mine
    @revealed = false
    @neighbors = 0
  end
  
  def set_mine(bool)
    @has_mine = bool
  end
  
  def reveal
    @reveal = true
  end
  
  def display_masked_state

    return self.neighbor_bomb_count if @revealed
    "_"
  end
  
  def neigbors
    
  end
  
  def neighbor_bomb_count
  end
end

a = Game.new(8, 4)
a.play_game

# b = Board.new(5, 4)
#
# p b.get_full_state
# p b.get_masked_state