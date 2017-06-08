module Validator::Boleto

  class BoletoValidator < BoletoValidatorBase

    attr_accessor :base_date              # A "data base" instituída pelo BACEN é: 07/10/1997.
    attr_accessor :digitable_line
    attr_accessor :barcode
    
    attr_accessor :bank_code              # Posição 01-03 = Identificação do banco (exemplo: 001 = Banco do Brasil)
    attr_accessor :currency_code          # Posição 04-04 = Código de moeda (exemplo: 9 = Real)
    
    attr_accessor :field_one              # Posição 05-09 = 5 primeiras posições do campo livre (posições 20 a 24 do código de barras)
    attr_accessor :field_one_digit        # Posição 10-10 = Dígito verificador do primeiro campo
    
    attr_accessor :field_two              # Posição 11-20 = 6ª a 15ª posições do campo livre (posições 25 a 34 do código de barras)
    attr_accessor :field_two_digit        # Posição 21-21 = Dígito verificador do segundo campo
    
    attr_accessor :field_tree             # Posição 22-31 = 16ª a 25ª posições do campo liv re (posições 35 a 44 do código de barras)
    attr_accessor :field_tree_digit       # Posição 32-32 = Dígito verificador do terceiro campo
    
    attr_accessor :general_digit          # Posição 33-33 = Dígito verificador geral (posição 5 do código de barras)
    attr_accessor :expiration_factor      # Posição 34-37 = Fator de vencimento (posições 6 a 9 do código de barras)
    attr_accessor :nominal_value          # Posição 38-47 = Valor nominal do título (posições 10 a 19 do código de barras)

    attr_accessor :expiration_date 
    attr_accessor :info_boleto

    def initialize(input)
      @digitable_line = input["digitableLine"]
      @info_boleto = translate_to_info_boleto(input)

      if validate_params
        @errors = []
        self.verify_digitable_line
        self.verify_blocks
        self.verify_expiration_date
      end
    end

    def base_date
      @base_date = Date.parse("07/10/1997")
    end

    def validate_params
      if digitable_line.blank?
        @info_boleto.errors.add("digitable_line", "Linha digitável não pode ser nula!")
        return false 
      end

      return true
    end

    def translate_to_info_boleto(input)
      info_boleto = InfoBoleto.new
      info_boleto.digitable_line = self.digitable_line
      info_boleto.due_date = self.expiration_date
      info_boleto.bar_code = self.barcode
      info_boleto.fine_value = input["fineValue"] 
      info_boleto.document_number = input["documentNumber"]
      info_boleto.issuer_name = input["issuerName"] 
      info_boleto.discount = input["discount"]

      return info_boleto
    end

    def barcode
      digitable_line[0..3] + digitable_line[32..46] + digitable_line[4..8] + digitable_line[10..19] + digitable_line[21..30] 
    end

    def barcode_to_calculate
      barcode[0..3] + barcode[5..43]
    end

    def general_digit
      @general_digit = barcode[4].to_i
    end

    def bank_code
      @bank_code = digitable_line[0..2] 
    end

    def currency_code
      @currency_code = digitable_line[3]
    end

    def field_one
      @field_one = digitable_line[0..8]
    end

    def field_one_digit
      @field_one_digit = digitable_line[9].to_i
    end

    def field_two
      @field_two = digitable_line[10..19]
    end

    def field_two_digit
      @field_two_digit = digitable_line[20].to_i
    end

    def field_tree
      @field_tree = digitable_line[21..30]
    end

    def field_tree_digit
      @field_tree_digit = digitable_line[31].to_i
    end

    def expiration_factor
      @expiration_factor = digitable_line[33..36]
    end

    def nominal_value
      @nominal_value = (digitable_line[37..44] + "." + digitable_line[45..46]).to_d
    end

    def expiration_date
      days = self.expiration_factor.to_s
      return true if boleto_sem_vencimento(days)
         
      @expiration_date = self.base_date.next_day(days.to_i)
    end

    def boleto_sem_vencimento(days)
      return true if days[days.length - 1] == 0
    end

    def verify_blocks
      result = mod_10(field_one)
      @info_boleto.errors.add("digitable_line", "Primeiro bloco de código é inválido") if field_one_digit != result

      result = mod_10(field_two)
      @info_boleto.errors.add("digitable_line", "Segundo bloco de código é inválido") if  field_two_digit != result

      result = mod_10(field_tree)
      @info_boleto.errors.add("digitable_line", "Terceiro bloco de código é inválido") if  field_tree_digit != result
          
      result = mod_11(barcode_to_calculate)
      @info_boleto.errors.add("digitable_line", "Linha digitavel é inválida") if  general_digit != result
    end

    def verify_expiration_date
       days = self.expiration_factor.to_s
       return true if boleto_sem_vencimento(days)
       
       result_date_diff = self.expiration_date - self.base_date
       
       if result_date_diff.to_i != days.to_i
         @info_boleto.errors.add("expiration_date", "Data de vencimento do boleto é invalida #{expiration_date.strftime("%m/%d/%Y")}")
       end

       if ((@expiration_date.to_date - Time.now.to_date).to_i < 0)
         @info_boleto.errors.add("expiration_date", "Boleto vencido #{expiration_date.strftime("%m/%d/%Y")}")
       end
   end

   def verify_digitable_line
     if digitable_line.length.to_i != 47 
       @info_boleto.errors.add("digitable_line", "A linha digitável está incompleta!' + #{digitable_line.length}") 
     end
   end
end
end