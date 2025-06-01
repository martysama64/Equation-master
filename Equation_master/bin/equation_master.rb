#!/usr/bin/env ruby

require "Equation_master_gem"

command = ARGV[0]

case command
when "solve"
  equation = ARGV[1]
  result = EquationMaster::Solver.solve(equation)
  # Красивый вывод результатов
  puts "Уравнение: #{equation}"
  puts "\nРезультаты:"
  puts "  Тип: #{result[:type]}"
  puts "  Коэффициенты: #{result[:coefficients].map { |k, v| "#{k}=#{v}" }.join(', ')}"
  if result[:discriminant]
    puts "  Дискриминант: #{result[:discriminant]}"
  end
  puts "  Корни:"
  result[:roots].each_with_index do |root, i|
    puts "  x#{i+1} = #{root}"
  end
  puts "  #{result[:conclusion]}"

when "plot"
  function = ARGV[1]
  options = {}
  ARGV[2..-1].each do |arg|
    if arg.start_with?("--")
      key, value = arg[2..-1].split('=')
      options[key.to_sym] = value.to_f
    end
  end
  EquationMaster::Plotter.plot(function, **options)

when "--help"
  puts <<~HELP
    Привет!
    
    Доступные команды:
     solve [ваше уравнение]
     plot [ваша функция] [параметры]
    
    Параметры построения графика:
     --from=[значение] (начало по x)
     --to=[значение] (конец по x)
     --height=[значение] (высота графика)
    
    Формат ввода уравнения(функции):
     x^2 парсится в "x в степени 2"
     степени кроме 2 и 3 не поддержиаются!
    
    Приятного использования!
  HELP

else
  puts "Неизвестная команда. Используйте --help для справки."
end