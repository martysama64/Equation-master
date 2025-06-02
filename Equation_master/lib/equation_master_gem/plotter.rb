module EquationMaster
  class Plotter
    def self.plot(function_str, from: -10, to: 10, height: 20)
      parsed_func = parse_function(function_str)
      width = (to - from).to_i
      step = (to - from).to_f / width
      x_values = Array.new(width + 1) { |i| from + i * step }
      y_values = x_values.map { |x| eval_function(parsed_func, x) }

      y_min = y_values.min
      y_max = y_values.max
      y_range = y_max - y_min
      y_range = 1 if y_range.zero?  # защита от деления на 0

      # нормализуем y для отображения
      normalized = y_values.map { |y| ((y - y_min) / y_range * (height - 1)).to_i }

      # создаём пустой график
      canvas = Array.new(height) { ' ' * (width + 1) }

      normalized.each_with_index do |y, i|
        row = height - 1 - y
        canvas[row][i] = '*'
      end

      # добавить ось x и y
      x_axis = (0...height).find { |i| i == height - 1 + (y_min > 0 ? -1 : 0) }
      y_axis = (0...width).find { |i| from + i * step >= 0 } || 0

      canvas.each_with_index do |line, i|
        line[y_axis] = '|' if line[y_axis] == ' '
      end
      canvas[x_axis] = ('-' * (width + 1)).tap { |s| s[y_axis] = '+' }

      puts canvas.map(&:rstrip).join("\n")
    end

    private

    # Примитивный парсер, преобразует строку "x^2 + 2x - 3" в валидное выражение Ruby
    def self.parse_function(str)
      str = str.gsub(/\bx\b/, 'x')
      str = str.gsub(/x\^(\d)/, 'x**\1')
      str
    end

    def self.eval_function(str, x)
      eval(str)
    rescue
      Float::NAN
    end
  end
end