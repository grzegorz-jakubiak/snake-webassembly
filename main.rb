require 'matrix'

class Board
  attr_reader :size

  def initialize(size = 30)
    @board = Matrix.zero(size)
    @size = size
  end

  def place_snake(snake)
    snake.coordinates.each do |points|
      @board[*points] = :snake
    end
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
  attr_writer :direction

  def initialize(x, y, length = 4)
    @points = Array.new(length) { |index| [x, y - index] }
    @direction = :up
  end

  def coordinates
    @points
  end

  def length
    @points.size
  end

  def head
    @points[0].dup
  end

  def tail
    @points.last.dup
  end

  def grow
    @points << tail
  end

  def move
    new_head = head
    case @direction
    when :up
      new_head[1] += 1
    when :down
      new_head[1] -= 1
    when :left
      new_head[0] -= 1
    when :right
      new_head[0] += 1
    end
    @points.pop
    @points.unshift(new_head)
  end
end
