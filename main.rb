require 'js'

DOCUMENT = JS.global[:document]
WINDOW = JS.global[:window]

LCD_BACKGROUND = '#A8B89A'
LCD_PIXEL = '#26352A'

class Snake
  attr_writer :direction

  def initialize(x, y, length = 4)
    @initial_x = x
    @initial_y = y
    @initial_length = length

    reset
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

  def reset
    @points = Array.new(@initial_length) do |index|
      [@initial_x, @initial_y - index]
    end

    @direction = :up
  end
end

class Engine
  def initialize
    @board_size = 30
    @snake = Snake.new(14, 14)
    @direction = :up
    @food = nil
    @game_over = false
    @tick = nil

    place_food

    @renderer = Renderer.new(
      @board_size,
      @snake,
      -> { @food },
      -> { @game_over }
    )
  end

  def start
    process_user_input
    start_game
  end

  private

  def process_user_input
    WINDOW.addEventListener('keydown') do |event|
      case event[:key].to_s
      when 'ArrowDown'
        @direction = :down unless @direction == :up || @game_over

      when 'ArrowUp'
        @direction = :up unless @direction == :down || @game_over

      when 'ArrowLeft'
        @direction = :left unless @direction == :right || @game_over

      when 'ArrowRight'
        @direction = :right unless @direction == :left || @game_over

      when ' '
        restart_game if @game_over
      end
    end
  end

  def start_game
    @tick = JS.global.setInterval(
      proc do
        update_simulation
        render
      end,
      200
    )
  end

  def update_simulation
    return if @game_over

    @snake.direction = @direction
    @snake.move

    head_x, head_y = @snake.head
    body = @snake.coordinates[0...-1]

    if head_x < 0 ||
       head_x >= @board_size ||
       head_y < 0 ||
       head_y >= @board_size ||
       body.include?(@snake.head)

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

  def restart_game
    @game_over = false
    @direction = :up
    @snake.reset
    @food = nil

    place_food
    start_game
  end

  def render
    @renderer.render
  end

  def stop_game
    JS.global.clearInterval(@tick)
    @tick = nil
  end
end

class Renderer
  def initialize(board_size, snake, food_getter, game_over_getter)
    @board_size = board_size
    @snake = snake
    @food_getter = food_getter
    @game_over_getter = game_over_getter

    @canvas_element = DOCUMENT.getElementById('canvas')
    @context = @canvas_element.getContext('2d')

    @canvas_width = @canvas_element[:width].to_i
    @canvas_height = @canvas_element[:height].to_i

    @cell_width = @canvas_width.to_f / @board_size
    @cell_height = @canvas_height.to_f / @board_size
  end

  def render
    @context[:fillStyle] = LCD_BACKGROUND

    @context.fillRect(
      0,
      0,
      @canvas_width,
      @canvas_height
    )

    @context[:fillStyle] = LCD_PIXEL
    @context[:strokeStyle] = LCD_PIXEL

    @context.strokeRect(
      0.5,
      0.5,
      @canvas_width - 1,
      @canvas_height - 1
    )

    render_snake
    render_food
    render_game_over if @game_over_getter.call
  end

  private

  def render_snake
    @context[:fillStyle] = LCD_PIXEL

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

    @context[:fillStyle] = LCD_PIXEL

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

    @context[:fillStyle] = LCD_PIXEL

    @context.fillRect(
      x,
      y,
      @cell_width,
      @cell_height
    )
  end

  def render_game_over
    @context.save

    @context[:fillStyle] = LCD_PIXEL

    @context.fillRect(
      0,
      0,
      @canvas_width,
      @canvas_height
    )

    @context[:fillStyle] = LCD_BACKGROUND
    @context[:font] = 'bold 40px sans-serif'
    @context[:textAlign] = 'center'
    @context[:textBaseline] = 'middle'

    @context.fillText(
      'Game Over',
      @canvas_width / 2.0,
      (@canvas_height / 2.0) - 25
    )

    @context[:font] = '20px sans-serif'

    @context.fillText(
      'Press Space to restart',
      @canvas_width / 2.0,
      (@canvas_height / 2.0) + 30
    )

    @context.restore
  end
end

Engine.new.start