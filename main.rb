require 'matrix'

class Board
  attr_reader :size

  def initialize(size = 30)
    @board = Matrix.zero(size)
    @size = size
  end

  def place_snake(snake)
    # TODO
  end

  def place_food
    loop do
      x = rand(@size)
      y = rand(@size)

      if @board[x, y] == 0
        @board[x, y] = :food
        break
      end
    end
  end
end

class Snake
  attr_reader :length
  attr_writer :direction

  def initialize(x, y)
    @head_x = x
    @head_y = y
    @length = 4
    @tail_x = x
    @tail_y = y + @length
    @direction = :up
  end

  def head
    [@head_x, @head_y]
  end

  def tail
    [@tail_x, @tail_y]
  end

  def grow(unit = 1)
    @length += unit
  end

  def move
    case @direction
    when :up
      # MOVE UP
    when :down
      # MOVE DOWN
    when :left
      # MOVE LEFT
    when :right
      # MOVE RIGHT
    end
  end
end
