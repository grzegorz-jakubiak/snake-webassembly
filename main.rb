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

  def head
    @points.last.dup
  end

  def tail
    @points.first.dup
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
    @food = nil
    @game_over = false

    place_food

    @renderer = Renderer.new(
      @board_size,
      @snake,
      -> { @food }
    )
  end

  def start
    process_user_input

    @tick = JS.global.setInterval(
      proc do
        update_simulation
        render
      end,
      900
    )
  end

  private

  def process_user_input
    WINDOW.addEventListener('keydown') do |event|
      case event[:key].to_s
      when 'ArrowDown'
        @direction = :down unless @direction == :up
      when 'ArrowUp'
        @direction = :up unless @direction == :down
      when 'ArrowLeft'
        @direction = :left unless @direction == :right
      when 'ArrowRight'
        @direction = :right unless @direction == :left
      end
    end
  end

  def update_simulation
    return if @game_over

    @snake.direction = @direction
    @snake.move

    head_x, head_y = @snake.head
    body = @snake.coordinates[0...-1]

    if head_x < 0 || head_x >= @board_size || head_y < 0 || head_y >= @board_size || body.include?(@snake.head)
      @game_over = true
      stop_game
      return
    end

    if @snake.head == @food
      @snake.grow
      @food = nil
      place_food
    end
  end

  def place_food
    return if @food

    loop do
      x = rand(@board_size)
      y = rand(@board_size)

      unless @snake.coordinates.include?([x, y])
        @food = [x, y]
        break
      end
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
  def initialize(board_size, snake, food_getter)
    @board_size = board_size
    @snake = snake
    @food_getter = food_getter

    @canvas_element = DOCUMENT.getElementById('canvas')
    @context = @canvas_element.getContext('2d')

    @canvas_width = @canvas_element[:width].to_i
    @canvas_height = @canvas_element[:height].to_i

    @cell_width = @canvas_width.to_f / @board_size
    @cell_height = @canvas_height.to_f / @board_size
  end

  def render
    @context.clearRect(0, 0, @canvas_width, @canvas_height)

    @context.strokeRect(
      0.5,
      0.5,
      @canvas_width - 1,
      @canvas_height - 1
    )

    render_snake
    render_food
  end

  private

  def render_snake
    @snake.coordinates.each do |x, y|
      draw_snake_cell(x, y)
    end
  end

  def render_food
    food = @food_getter.call
    return unless food

    grid_x, grid_y = food

    center_x = (grid_x * @cell_width) + (@cell_width / 2.0)
    center_y = (grid_y * @cell_height) + (@cell_height / 2.0)

    @context.save
    @context.translate(center_x, center_y)
    @context.rotate(Math::PI / 4.0)

    @context.fillRect(
      -@cell_width / 2.0,
      -@cell_height / 2.0,
      @cell_width,
      @cell_height
    )

    @context.restore
  end

  def draw_snake_cell(grid_x, grid_y)
    x = grid_x * @cell_width
    y = grid_y * @cell_height

    @context.fillRect(
      x,
      y,
      @cell_width,
      @cell_height
    )
  end
end