module Validator::Boleto

    #################################################################################################################################################################
    # 'Composição do Código de Barras
    #     'POSIÇÃO    -  TAM  - CONTEÚDO
    #     '01  01    -   1   - Identificação do Produto
    #     '                       Constante "8" para identificar arrecadação
    #     '02  02	-   1   - Identificação do Segmento 
    #     '                       1. Prefeituras
    #     '                       2. Saneamento
    #     '                       3. Energia Elétrica e Gás
    #     '                       4. Telecomunicações
    #     ' 	                    5. Órgãos Governamentais
    #     '                       6. Carnes e Assemelhados ou demais Empresas / Órgãos que serão identificadas através do CNPJ.
    #     '                       7. Multas de trânsito
    #     '                       9. Uso interno do banco
    #     '03  03	-   1   - Identificação do valor real ou referência
    #     '                       Geralmente "6" valor a ser cobrado efetivamente em reais.
    #     '04  04	-   1   - Dígito verificador geral (módulo 10 )
    #     '05  15    -   11  - Valor
    #     '== opção 1 ==
    #     '16  19	-   4   - Identificação da Empresa/Órgão
    #     '20  44	-   25  - Campo livre de utilização da Empresa/Órgão
    #     '== opção 2 ==
    #     '16  23    -   8   - CNPJ / MF
    #     '24  44    -   21  - Campo livre de utilização da Empresa/Órgão
    #################################################################################################################################################################

    # Barcode 
    #################################################################################################################################################################    
    # Linha digitável (motando a partir do código de barras): 
    # 89610000000 0 59980001011 9 05333201006 4 26000015744 6

    # Código de barras:
    # 89610000000599800010110533320100626000015744 

    # Destrinchando o código de barras...
    # =======================
    # 8 = Identificação do produto - Arrecadação
    # 9 = Identificação do segmento - Uso exclusivo do banco
    # 6 = Identicação do tipo valor referência - 6 - Valor cobrado em reais com dígito verificador calculado usando módulo 10
    # 1 = Dígito verificados geral do cód. de barras - Calculado usando o mesmo dígito verificados da posição 3 do cód. de barras (no caso módulo 10)
    # 00000005998 - Valor da cobrança - No caso R$ 59,58
    # 0001 - Código de compensação do banco com 4 dígitos (0001 - Banco do Brasil)
    # 01 - Dígitos 11 e 12 do CNPJ do órgão que vai receber o dinheiro (CNPJ ORG - 66.308.410/0001-02)
    # 105333 - Código do convênio entre o banco e o órgão que vai receber o dinheiro (no exemplo é JRIMUM ORG -)
    # 20100626 - Data de vencimento no formado AAAAMMDD
    # 000015744 - Número da guia - Seria por exemplo o nosso número do boleto
    
    #################################################################################################################################################################

class ConcessionaireBoletoValidator < BoletoValidatorBase

  attr_accessor :digitable_line
  attr_accessor :barcode
  attr_accessor :info_boleto

  attr_accessor :product_code              # Posicao 01-01           
  attr_accessor :segment_code              # Posicao 02-02
  attr_accessor :currency_code             # Posicao 03-03
  attr_accessor :general_digit             # Posicao 04-04
  attr_accessor :amount                    # Posicao 05-15
  attr_accessor :identifier_company_entity # Posicao 16-19
  attr_accessor :company_internal_code     # Posicao 20-44
  attr_accessor :company_document          # Posicao 16-23
  attr_accessor :company_interal_code_2    # Posicao 24-44

  attr_accessor :field_one              
  attr_accessor :field_one_digit        
    
  attr_accessor :field_two              
  attr_accessor :field_two_digit        
    
  attr_accessor :field_tree             
  attr_accessor :field_tree_digit       

  attr_accessor :field_four             
  attr_accessor :field_four_digit       
   
  def initialize(input)
    @digitable_line = input["digitableLine"]
    @info_boleto = translate_to_info_boleto(input)

    if validate_params
      @errors = []
      self.verify_digitable_line
      self.validate_blocks
      self.validate_general_code
    end
  end

  def validate_params
    if digitable_line.blank?
      @info_boleto.errors.add("digitable_line", "Digitable line should not be null!")
      return false 
    end

    return true
  end

  def translate_to_info_boleto(input)
    info_boleto = InfoBoleto.new
    info_boleto.digitable_line = self.digitable_line
    info_boleto.fine_value = input["fineValue"] 
    info_boleto.bar_code = barcode
    info_boleto.document_number = input["documentNumber"]
    info_boleto.issuer_name = input["issuerName"] 
    info_boleto.discount = input["discount"]

    return info_boleto
  end

  def field_one
    @field_one = digitable_line[0..10]
  end

  def field_one_digit
    @field_one_digit = digitable_line[11].to_i
  end

  def field_two
    @field_two = digitable_line[12..22]
  end

  def field_two_digit
    @field_two_digit = digitable_line[23].to_i
  end

  def field_tree
   @field_tree = digitable_line[24..34]
  end

  def field_tree_digit
    @field_tree_digit = digitable_line[35].to_i
  end

  def field_four
    @field_four = digitable_line[36..46]
  end

  def field_four_digit
    @field_four_digit = digitable_line[47].to_i
  end

  def barcode
    @barcode = digitable_line[0..10] + digitable_line[12..22] + digitable_line[24..34] + digitable_line[36..46] 
  end

  def barcode_to_calculate
    @barcode_to_calculate = @barcode[0..2] + @barcode[4..46] 
  end

  def general_digit 
    @general_digit = barcode[3].to_i
  end

  def currency_code
    @currency_code = barcode[2].to_i
  end

  def validate_blocks
    result = calculate_mod(field_one)
    @info_boleto.errors.add("digitable_line", "First block is invalid") if field_one_digit != result

    result = calculate_mod(field_two)
    @info_boleto.errors.add("digitable_line", "Second block is invalid") if  field_two_digit != result
    
    result = calculate_mod(field_tree)
    @info_boleto.errors.add("digitable_line", "Third block is invalid") if  field_tree_digit != result

    result = calculate_mod(field_four)
    @info_boleto.errors.add("digitable_line", "Fourth block is invalid") if  field_four_digit != result
  end

  def validate_general_code
    result = calculate_mod(barcode_to_calculate)  
    @info_boleto.errors.add("digitable_line", "Digitable line is invalid") if general_digit != result
  end

  def calculate_mod(input)
    if currency_code == 6 || currency_code == 7
      return mod_10(input)
    else
      return special_mod_11(input)
    end
  end

  def verify_digitable_line
    @info_boleto.errors.add("digitable_line", "The digitable line is incomplete!' + #{digitable_line.length}") if digitable_line.length.to_i != 48 
  end
end

end