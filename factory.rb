module Validator::Boleto

  class Factory
    CODIGO_BOLETO_ARRECADACAO = "8"
    
    def service
      @service 
    end

    def initialize(params_info)
      if params_info["digitableLine"][0] != CODIGO_BOLETO_ARRECADACAO 
        @service = BoletoValidator.new(params_info)
      else
        @service = ConcessionaireBoletoValidator.new(params_info)
      end

      return @service
    end
  end

end


