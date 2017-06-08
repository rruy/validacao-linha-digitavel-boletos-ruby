# Validacao de Linha digitavel de boleto


Referências:

Documentação com o padrão de geração de boletos
https://cmsportal.febraban.org.br/Arquivos/documentos/PDF/Layout%20-%20C%C3%B3digo%20de%20Barras%20-%20Vers%C3%A3o%205%20-%2001_08_2016.pdf


Boletos de cobrança:


  'LEIAUTE DO CÓDIGO DE BARRAS PADRÃO (vale para qualquer banco)
  '...............................................................    
  '   N.    POSIÇÕES     PICTURE     USAGE        CONTEÚO                
  '...............................................................    
  '    01    001 a 003    9/003/      Display      Identificação do banco
  '    02    004 a 004    9/001/      Display      9 /Real/
  '(a) 03    005 a 005    9/001/      Display      DV /*/
  '(b) 04    006 a 009    9/004/      Display      fator de vencimento
  '    05    010 a 019    9/008/v99   Display      Valor
  '    06    020 a 044    9/025/      Display      CAMPO LIVRE
  '...............................................................    

Boletos de Arrecadação de Concessionária:


    Composição do Código de Barras
         'POSIÇÃO    -  TAM  - CONTEÚDO
         '01  01    -   1   - Identificação do Produto
         '                       Constante "8" para identificar arrecadação
         '02  02	-   1   - Identificação do Segmento 
         '                       1. Prefeituras
         '                       2. Saneamento
         '                       3. Energia Elétrica e Gás
         '                       4. Telecomunicações
         ' 	                    5. Órgãos Governamentais
         '                       6. Carnes e Assemelhados ou demais Empresas / Órgãos que serão identificadas através do CNPJ.
         '                       7. Multas de trânsito
         '                       9. Uso interno do banco
         '03  03	-   1   - Identificação do valor real ou referência
         '                       Geralmente "6" valor a ser cobrado efetivamente em reais.
         '04  04	-   1   - Dígito verificador geral (módulo 10 )
         '05  15    -   11  - Valor
         '== opção 1 ==
         '16  19	-   4   - Identificação da Empresa/Órgão
         '20  44	-   25  - Campo livre de utilização da Empresa/Órgão
         '== opção 2 ==
         '16  23    -   8   - CNPJ / MF
         '24  44    -   21  - Campo livre de utilização da Empresa/Órgão
    
    Linha digitável (motando a partir do código de barras): 
    89610000000 0 59980001011 9 05333201006 4 26000015744 6

    Código de barras:
    89610000000599800010110533320100626000015744 

    Destrinchando o código de barras...
    
    8 = Identificação do produto - Arrecadação
    9 = Identificação do segmento - Uso exclusivo do banco
    6 = Identicação do tipo valor referência - 6 - Valor cobrado em reais com dígito verificador calculado usando módulo 10
    1 = Dígito verificados geral do cód. de barras - Calculado usando o mesmo dígito verificados da posição 3 do cód. de barras (no caso módulo 10)
    00000005998 - Valor da cobrança - No caso R$ 59,58
    0001 - Código de compensação do banco com 4 dígitos (0001 - Banco do Brasil)
    01 - Dígitos 11 e 12 do CNPJ do órgão que vai receber o dinheiro (CNPJ ORG - 66.308.410/0001-02)
    105333 - Código do convênio entre o banco e o órgão que vai receber o dinheiro (no exemplo é JRIMUM ORG -)
    20100626 - Data de vencimento no formado AAAAMMDD
    000015744 - Número da guia - Seria por exemplo o nosso número do boleto


