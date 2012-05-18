==================================================================
ANDRE AMBROSIO BOECHAT
GILBERTO ALVES SANTOS SEGUNDO
Tue Dec  8 10:27:51 BRST 2009
==================================================================

####################################################
#### Operações aritméticas/lógicas implementadas ###
####################################################
    -> ADD, ADC e SUB
    -> AND, OR e XOR
    
    
####################################################
#### Saltos de código (jumps) implementados     ####
####################################################
    -> JMP (000)- jump incondicional, pula para o endereço contido na instrução
    -> JZ (001) - pular se o resultado for igual a zero - implementado para todas as operações
    -> JNZ (010) - pular se o resultado for diferente de zero - implementado para todas as operações
    -> JS (011) - pular se o resultado for negativo - implementado somente para operação de subtração
    -> JC (100) - pular se houve carry na última operação. Implementado somente para operação de adição
    -> JO (101) - pular se houve overflow - implementado somente para operações de soma e multiplicação
    -> CALL (110) - Empilha o próximo endereço e faz pc apontar para o endereço contido na instrução
    -> RETURN (111) - desempilha o endereço e faz o pc apontar para ele.

#####################
#### Memória RAM:####
#####################
    Para imprimir o conteúdo da RAM até a instrução corrente, exclusive, basta armazenar
    os bits 11111111 em qualquer endereço.

##################################
#### Porta Paralela de 8 bits ####
##################################
    Configurável nos endereços 10h a 13h, da seguinte forma:
    -> 10h IODTA: entrada de dados/saida de dados
    -> 11H IODIR : direção (bit 1 significa saida)
    -> 12H IOSET: bit 1 numa posição significa que este bit é setado e os outros
    permanecem inalterados
    -> 13H IOCLR : bit 1 numa posição significa que este é resetado e os outros permanecem
    inalterados
