module Validator::Boleto

  class BoletoValidatorBase 

      def mod_10(field) #Mod 10
       sum = 0
       weight = 2
       count = field.length - 1
       result_multiply = []
       
       while (count >= 0) 
          pos_field = field[count]
          multiply = (pos_field.to_i * weight)
          result_multiply << multiply  
          weight = (weight == 2 ? 1 : 2)
          count -= 1
       end

       result_multiply.each do |res|
         result_number = res.to_s
         if result_number.length > 0
             for i in (0..(result_number.length - 1))
                 sum += result_number[i].to_i
             end
         else
             sum += result_number.to_i
         end    
       end  

       result_digit = 10 - (sum % 10);
       result_digit = 0 if (result_digit == 10)
       result_digit
    end

    def mod_11(field) #Mod 11
       weight = 2
       count = field.length - 1
       result_multiply = []
       
       while (count >= 0)
          pos_field = field[count]
          multiply = (pos_field.to_i * weight)
          result_multiply << multiply 
          
          if weight == 9
            weight = 2
          else  
            weight += 1 
          end

          count -= 1
       end
       
       result_digit = 11 - (result_multiply.sum % 11);
       
       return 1 if result_digit > 9
       return 1 if result_digit == 0

       result_digit
    end

    def special_mod_11(field)
       weight = 2
       count = field.length - 1
       result_multiply = []
       
       while (count >= 0)
          pos_field = field[count]
          multiply = (pos_field.to_i * weight)
          result_multiply << multiply 
          
          if weight == 9
            weight = 2
          else  
            weight += 1 
          end

          count -= 1
       end
       
       result_digit = (((result_multiply.sum * 10) % 11) % 10)
    end

  end

end