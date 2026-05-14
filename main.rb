require 'js'
require 'matrix'

DOCUMENT = JS.global[:document]
WINDOW = JS.global[:window]

class Board
  include Enumerable

  attr_reader :size

  def initialize(size = 30)
    @board = Matrix.zero(size)
    @size = size
  end

  def [](x, y)
    return nil if x.negative? || x > size - 1 || y.negative? || y > size - 1
    @board[x, y]
  end

  def each(&block)
    return to_enum :each, which unless block_given?
    @board.each_with_index do |elem, row_index, col_index|
      yield elem, row_index, col_index
    end
  end

  def place_snake(snake)
    snake.coordinates.each do |points|
      @board[*points] = :snake
    end
  end

  def place_food
    return if @board.one?(:food)

    loop do
      x = rand(@size)
      y = rand(@size)

      if @board[x, y] == 0
        @board[x, y] = :food
        break
      end
    end
  end

  def clear_but_food
    each do |e, row, col|
      next if e == :food

      @board[row, col] = 0
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
    @points.last.dup
  end

  def tail
    @points[0].dup
  end

  def grow
    @points.prepend(tail)
  end

  def move
    new_head = head
    case @direction
    when :up
      new_head[1] -= 1
    when :down
      new_head[1] += 1
    when :left
      new_head[0] -= 1
    when :right
      new_head[0] += 1
    end
    @points.shift
    @points.push(new_head)
  end
end

class Engine
  def initialize
    @board = Board.new(30)
    @snake = Snake.new(14, 14)
    @renderer = Renderer.new(@board)
    @direction = :up
  end

  def start
    process_user_input

    @tick = JS.global.setInterval(
      proc do
        update_simulation
        render
      end,
    900)
  end

  private

  def process_user_input
    WINDOW.addEventListener('keydown') do |event|
      case event[:key].to_s
      when 'ArrowDown'
        @direction = :down
      when 'ArrowUp'
        @direction = :up
      when 'ArrowLeft'
        @direction = :left
      when 'ArrowRight'
        @direction = :right
      end
    end
  end

  def update_simulation
    @snake.direction = @direction
    @snake.move

    case @board[*@snake.head]
    when nil, :snake
      stop_game
      return
    when :food
      @snake.grow
    end

    @board.clear_but_food
    @board.place_snake(@snake)
    @board.place_food
  end

  def render
    @renderer.render
  end

  def stop_game
    JS.global.clearInterval(@tick)
  end
end

class Renderer
  def initialize(board)
    @board = board
    @canvas_element = DOCUMENT.getElementById('canvas')
    @context = @canvas_element.getContext('2d')
    @width_ratio = @canvas_element[:width].to_i / @board.size
    @height_ratio = @canvas_element[:height].to_i / @board.size
  end

  def render
    @context.clearRect(0, 0, @canvas_element[:width], @canvas_element[:height])
    @context.strokeRect(0, 0, @canvas_element[:width], @canvas_element[:height])
    @board.each do |e, row, col|
      case e
      when :snake
        x = row * @width_ratio
        y = col * @height_ratio
        @context.fillRect(x, y, 10, 10)
      when :food
        x = row * @width_ratio
        y = col * @height_ratio
        @context.fillRect(x, y, 10, 10)
      end
    end
  end
end