class InfoBoleto < ActiveModel

  attr_accessor :digitable_line
  attr_accessor :due_date
  attr_accessor :bar_code
  attr_accessor :fine_value 
  attr_accessor :document_number
  attr_accessor :issuer_name 
  attr_accessor :discount

end