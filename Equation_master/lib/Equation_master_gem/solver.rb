module EquationMaster
  class Solver
    def self.solve(equation)
      parsed = parse_equation(equation)
      
      case parsed[:degree]
      when 1
        solve_linear(parsed[:coefficients])
      when 2
        solve_quadratic(parsed[:coefficients])
      when 3
        solve_cubic(parsed[:coefficients])
      else
        raise "Неподдерживаемая степень уравнения"
      end
    end

    private

    def self.parse_equation(equation)

      # Удаление пробелов
      equation = equation.gsub(/\s+/, '').downcase
      
      # Проверка наличия =
      unless equation.include?('=')
        raise "Нет знака равенства"
      end
      
      left, right = equation.split('=', 2)
      
      # Перенос правой части влево
      right_terms = parse_terms(right)
      right_terms.each { |t| t[:coef] *= -1 }
      all_terms = parse_terms(left) + right_terms
      
      # Определение степеней
      coefficients = {}
      all_terms.each do |term|
        degree = term[:degree]
        coefficients[degree] ||= 0
        coefficients[degree] += term[:coef]
      end
      
      # Максимальная степень
      max_degree = coefficients.keys.max || 0
      
      # Отсортированный массив степеней, от старшей к младшей
      coeff_array = []
      (max_degree.downto(0)).each do |degree|
        coeff_array << (coefficients[degree] || 0)
      end
      
      { degree: max_degree, coefficients: coeff_array }
    end

    def self.parse_terms(expr)
      return [] if expr.empty?
      
      terms = []
      current_term = ''
      
      expr.each_char do |c|
        if (c == '+' || c == '-') && !current_term.empty?
          terms << parse_term(current_term)
          current_term = c
        else
          current_term << c
        end
      end
      
      terms << parse_term(current_term) unless current_term.empty?
      terms
    end

    def self.parse_term(term_str)
      if term_str.include?('x')
        parts = term_str.split('x', 2)
        coef_part = parts[0]
        
        coef = if coef_part.empty? || coef_part == '+'
                  1
                elsif coef_part == '-'
                  -1
                else
                  coef_part.to_f
                end
        
        if parts[1].start_with?('^')
          degree = parts[1][1..-1].to_i
        else
          degree = 1
        end
        { coef: coef, degree: degree }
      else
        { coef: term_str.to_f, degree: 0 }
      end
    end

    def self.solve_linear(coeffs)
      a, b = coeffs
      x = -b / a
      
      {
        type: "Линейное уравнение",
        coefficients: { a: a, b: b },
        roots: [x],
        conclusion: "1 действительный корень"
      }
    end

    def self.solve_quadratic(coeffs)
      a, b, c = coeffs
      discriminant = b**2 - 4*a*c
      
      results = {
        type: "Квадратное уравнение",
        coefficients: { a: a, b: b, c: c },
        discriminant: discriminant
      }
      
      if discriminant > 0
        sqrt_d = Math.sqrt(discriminant)
        x1 = (-b + sqrt_d) / (2*a)
        x2 = (-b - sqrt_d) / (2*a)
        results.merge!({
          roots: [x1, x2],
          conclusion: "D > 0 → 2 действительных корня"
        })
      elsif discriminant == 0
        x = -b / (2*a)
        results.merge!({
          roots: [x],
          conclusion: "D = 0 → 1 действительный корень (кратный)"
        })
      else
        real = -b / (2*a)
        imag = Math.sqrt(-discriminant) / (2*a)
        results.merge!({
          roots: [Complex(real, imag), Complex(real, -imag)],
          conclusion: "D < 0 → 2 комплексных корня"
        })
      end
      
      results
    end

    def self.solve_cubic(coeffs)
        a, b, c, d = coeffs
        
        # Приведение к виду x³ + px² + qx + r = 0
        if a.abs < 1e-10
          return solve_quadratic([b, c, d])
        end
        
        p = b / a.to_f
        q = c / a.to_f
        r = d / a.to_f
        
        q_val = (p**2 - 3*q) / 9.0
        r_val = (2*p**3 - 9*p*q + 27*r) / 54.0
        
        discriminant = r_val**2 - q_val**3
        
        results = {
          type: "Кубическое уравнение",
          coefficients: { a: a, b: b, c: c, d: d },
          q: q_val,
          r: r_val,
          discriminant: discriminant
        }
        
        if discriminant > 0
          sqrt_d = Math.sqrt(discriminant)
          a_val = -r_val.sign * (r_val.abs + sqrt_d)**(1.0/3)
          b_val = q_val / a_val unless a_val == 0
          
          x1 = (a_val + b_val) - p/3.0
          x2 = Complex(-(a_val+b_val)/2 - p/3, (a_val-b_val)*Math.sqrt(3)/2)
          x3 = Complex(-(a_val+b_val)/2 - p/3, -(a_val-b_val)*Math.sqrt(3)/2)
          
          results.merge!({
            roots: [x1, x2, x3],
            conclusion: "1 действительный и 2 комплексных корня"
          })
        elsif discriminant == 0
          x1 = 2 * r_val**(1.0/3) - p/3.0
          x2 = -r_val**(1.0/3) - p/3.0
          x3 = x2
          
          results.merge!({
            roots: [x1, x2, x3],
            conclusion: "3 действительных корня (хотя бы два совпадают)"
          })
        else
          theta = Math.acos(r_val / Math.sqrt(q_val**3))
          sqrt_q = Math.sqrt(q_val)
          
          x1 = -2 * sqrt_q * Math.cos(theta/3) - p/3.0
          x2 = -2 * sqrt_q * Math.cos((theta + 2*Math::PI)/3) - p/3.0
          x3 = -2 * sqrt_q * Math.cos((theta - 2*Math::PI)/3) - p/3.0
          
          results.merge!({
            roots: [x1, x2, x3].sort,
            conclusion: "3 различных действительных корня"
          })
        end
        
        results
      end
  end
end

# Добавление метод sign для Numeric
class Numeric
  def sign
    self < 0 ? -1 : 1
  end
end