require 'js'
require 'matrix'

class Board
  attr_reader :size

  def initialize(size = 30)
    @board = Matrix.zero(size)
    @size = size
  end

  def [](x, y)
    @board[x, y]
  end

  def each(&block)
    return to_enum :each, which unless block_given?
    @board.each_with_index {|e, row, col| yield e, row, col }
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

  def clear
    @board = Matrix.zero(@size)
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

class Engine
  def initialize
    @board = Board.new(30)
    @snake = Snake.new(14, 14)
  end

  def start
    loop do
      @board.place_snake(@snake)
      @board.place_food
      @snake.move
      case @board[*@snake.head]
      when 0
        # OKAY
      when :food
        @snake.grow
      when nil, :snake
        break
      end
      @board.clear
    end
  end
end

class Renderer
  def initalize(board)
    @board = board
    @canvas_element = JS.global[:document].getElementById('canvas')
    @context = @canvas_element.getContext('2d')
    @width_ratio = @canvas_element[:width] / @board.size
    @height_ration = @canvas_element[:height] / @board.size
  end

  def render
    @context.strokeRect(0, 0, @canvas_element[:width], @canvas_element[:height])
    @board.each do |e, row, col|
      if e == :snake
        x = row * @width_ratio
        y = col * @height_ratio
        context.fillRect(x, y, 10, 10)
      end
    end
  end
end
