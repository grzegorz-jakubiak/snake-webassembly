require 'js'

DOCUMENT = JS.global[:document]
WINDOW = JS.global[:window]

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
    @board_size = 30
    @snake = Snake.new(14, 14)
    @direction = :up
    @food = place_food
    @renderer = Renderer.new(@board_size, @snake, @food)
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
    place_food
    @snake.move

    head_x, head_y = @snake.head
    body = @snake.coordinates[0...-1]

    if head_x.negative? ||
      head_x >= @board_size ||
      head_y.negative? ||
      head_y >= @board_size || body.include?(@snake.head)
      stop_game
    end

    if @snake.head == @food
      @snake.grow
      @food = nil
    end
  end

  def place_food
    return if @food

    loop do
      x = rand(@board_size)
      y = rand(@board_size)

      break @food = [x, y] unless @snake.coordinates.include?([x, y])
    end
  end

  def render
    @renderer.render
  end

  def stop_game
    JS.global.clearInterval(@tick)
  end
end

class Renderer
  def initialize(board_size, snake, food)
    @board_size = board_size
    @snake = snake
    @food = food
    @canvas_element = DOCUMENT.getElementById('canvas')
    @context = @canvas_element.getContext('2d')
    @width_ratio = @canvas_element[:width].to_i / @board_size
    @height_ratio = @canvas_element[:height].to_i / @board_size
  end

  def render
    @context.clearRect(0, 0, @canvas_element[:width], @canvas_element[:height])
    @context.strokeRect(0, 0, @canvas_element[:width], @canvas_element[:height])
    @snake.coordinates.each do |(x, y)|
      x = x * @width_ratio
      y = y * @height_ratio
      @context.fillRect(x, y, 10, 10)
    end
    if @food
      x = @food[0] * @width_ratio
      y = @food[1] * @height_ratio
      @context.fillRect(x, y, 10, 10)
    end
  end
end