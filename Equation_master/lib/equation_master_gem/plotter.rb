module EquationMaster
  class Plotter
    WINDOW_WIDTH = 80
    WINDOW_HEIGHT = 20

    def self.plot(function_str = nil, **options)
      plot_width  = (options[:width]  || 10).to_f
      plot_height = (options[:height] || 10).to_f

      grid = initialize_grid
      draw_axes(grid)

      (0...Plotter::WINDOW_HEIGHT).each do |row|
        (0...Plotter::WINDOW_WIDTH).each do |col|
          if Plotter.should_plot?(function_str, col, row, plot_width, plot_height)
            grid[row][col] = '•'
          end
        end
      end

      add_axis_labels(grid, plot_width, plot_height)
      render(grid)
    end

    def self.initialize_grid
      Array.new(WINDOW_HEIGHT) { Array.new(WINDOW_WIDTH, ' ') }
    end

    def self.draw_axes(grid)
      center_x = WINDOW_WIDTH / 2
      center_y = WINDOW_HEIGHT / 2

      (0...WINDOW_WIDTH).each do |x|
        grid[center_y][x] = '─'
      end

      (0...WINDOW_HEIGHT).each do |y|
        grid[y][center_x] = '│'
      end

      grid[center_y][center_x] = '┼'

      grid[center_y][WINDOW_WIDTH - 1] = '>'
      grid[0][center_x] = '^'
    end

    def self.add_axis_labels(grid, plot_width, plot_height)
      center_x = WINDOW_WIDTH / 2
      center_y = WINDOW_HEIGHT / 2

      x_values = [
        -plot_width / 2.0,
        -plot_width / 4.0,
         plot_width / 4.0,
         plot_width / 2.0
      ]

      x_values.each do |x_val|
        px = (( (x_val + (plot_width / 2.0)) / plot_width ) * (WINDOW_WIDTH - 1)).round
        label = format_label(x_val)

        row = center_y + 1
        next if row >= WINDOW_HEIGHT

        start_col = px - (label.length / 2)
        (0...label.length).each do |i|
          col = start_col + i
          if col.between?(0, WINDOW_WIDTH - 1)
            grid[row][col] = label[i]
          end
        end
      end

      y_values = [
         plot_height / 2.0,
         plot_height / 4.0,
        -plot_height / 4.0,
        -plot_height / 2.0
      ]

      y_values.each do |y_val|
        py = (( ( (plot_height / 2.0) - y_val ) / plot_height ) * (WINDOW_HEIGHT - 1)).round
        label = format_label(y_val)
        
        col_end = center_x - 1
        start_col = col_end - label.length + 1
        next if py < 0 || py >= WINDOW_HEIGHT

        (0...label.length).each do |i|
          col = start_col + i
          if col.between?(0, WINDOW_WIDTH - 1)
            grid[py][col] = label[i]
          end
        end
      end
    end

    def self.format_label(value)
      str = sprintf('%.2f', value)
      str.sub!(/\.?0+$/, '')
      str
    end

    def self.render(grid)
      grid.each { |row| puts row.join }
    end

    def self.should_plot?(function_str, col, row, plot_width, plot_height)
      expr = function_str.gsub(/\s+/, '').gsub('^', '**')

      unless expr =~ /\A[0-9x\+\-\*\/\.\(\)\^]+\z/
        raise ArgumentError, "Некорректный формат функции: #{function_str}"
      end

      f = eval("->(x) { #{expr} }")

      x_min = ( col.to_f           / (WINDOW_WIDTH - 1)) * plot_width - (plot_width / 2.0)
      x_max = ((col + 1).to_f / (WINDOW_WIDTH - 1)) * plot_width - (plot_width / 2.0)

      begin
        y1 = f.call(x_min)
        y2 = f.call(x_max)
        return false unless y1.is_a?(Numeric) && y1.finite? &&
                            y2.is_a?(Numeric) && y2.finite?
      rescue
        return false
      end

      y_center = (((WINDOW_HEIGHT - 1 - row).to_f / (WINDOW_HEIGHT - 1)) * plot_height) - (plot_height / 2.0)

      cell_half = (plot_height / (WINDOW_HEIGHT - 1)) / 2.0
      y_cell_min = y_center - cell_half
      y_cell_max = y_center + cell_half

      y_low_segment  = [y1, y2].min
      y_high_segment = [y1, y2].max

      return false if y_high_segment < y_cell_min || y_low_segment > y_cell_max

      true
    end

  end
end