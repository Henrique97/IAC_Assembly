; *********************************************************************
; * IST-UL
; *********************************************************************
; Alunos:
;	 Franscico Rola	  84717
;	 Henrique Almeida 84725
;	 Tomás Oliveira   84773
; **********************************************************************
; * Constantes
; **********************************************************************
; **********************************************************************
; * Portos
; **********************************************************************
BOTOES_PRESSAO   EQU  800CH ; endereço do porto dos botões de pressão
SEMAFOROS 	     EQU  8012H	; endereço dos semáforos
SEMAFOROS_PN	 EQU  8014H ; endereço dos semaforos de passagem de nível
AGULHAS          EQU  8016H ; endereço do porto das agulhas
SELECAO          EQU  8018H	; endereço do porto de seleção de comboio e comando		
COMANDO		     EQU  801AH	; endereço do porto onde dar comandos para os comboios
SENSOR_INFO	     EQU  801EH	; endereço do porto dos sensores (informação)
; **********************************************************************
; * Comboios seleção
; **********************************************************************
COMBOIO_0		 EQU  0000H ; endereço do comboio 0
COMBOIO_1		 EQU  0001H ; endereço do comboio 1
; **********************************************************************
; * Velocidades
; **********************************************************************
VEL_NULA	EQU  0 ;endereço velocidade minima para a frente
VEL_MAX	 	EQU  3H ;endereço velocidade maxima para tras
; **********************************************************************
; * Valores das Agulhas
; **********************************************************************
AGU_ESQ             EQU  1     ; agulha: direção esquerda 
AGU_DIR             EQU  2     ; agulha: direção direita
; **********************************************************************
; * SEMAFOROS
; **********************************************************************
SEM_VERDE           EQU  2        	; cor dos semáforos (verde)
SEM_VERMELHO        EQU  1        	; cor dos semáforos (vermelho)
SEM_CINZENTO        EQU  0         	; cor dos semáforos (cinzento)

;***********************************
; * SENSORES
;***********************************
NAO_HA_EVENTO   	EQU 0FFH		;indica que nao houve passagem por sensor
;***********************************
; * GERAL
;***********************************
SP_inicial			EQU	5000H
PLACE 1000H
TABELA_INTERRUPCOES:
	WORD 	  rot0
	WORD      rot1                ; rotina de tratamento da interrupção 1

agulha_escolhida: STRING 0FH
contador0: STRING 0H				  ; contador da estacao 0
contador1: STRING 0H				  ; contador da estacao 1
contador2: STRING 0H				  ; contador da estacao 2
ligacont0: STRING 0H				  ; liga contador 0
ligacont1: STRING 0H				  ; liga contador 1
ligacont2: STRING 0H				  ; liga contador 2
incontador0: STRING 0H			  ; contador inicial da rotina 0 
incontador1: STRING 0H			  ; contador inicial da rotina 1
incontador2: STRING 0H			  ; contador inicial da rotina 2

		
sensor_lido:
	STRING 			NAO_HA_EVENTO
	STRING 			NAO_HA_EVENTO
	

velocidade_comboios:			  ; tabela onde se armazena as velocidades 
	STRING 			3			  ; velocidade do comboio 0
	STRING 			3			  ; velocidade do comboio 1
	
trocos_seguintes:				
	STRING 			0FH
	STRING			0FH
	STRING 			07H
	STRING			05H
	STRING 			05H
	STRING 			0H
	STRING 			02H
	STRING 			01H
	STRING 			09H
	STRING 			06H

direcao_agulhas:                  ; tabela para as direções das agulhas (ESQUERDA ou DIREITA).
                                  ; Por omissão, todas as agulhas estão com a direção para a DIREITA
     STRING    AGU_DIR            ; direção da agulha 0
     STRING    AGU_DIR            ; direção da agulha 1
     STRING    AGU_DIR            ; direção da agulha 2
     STRING    AGU_DIR            ; direção da agulha 3
	
trocos_ocupados:
	STRING 		04H				  ; troco ocupado pelo comboio 0 (o comboio comeca no troco 4)
	STRING 		07H				  ; troco ocupado pelo comboio 1 (o comboio comeca no troco 7)
sensores_ciclo_anterior:
	STRING 		0FH
	STRING 		0FH
	
cores_semaforos_07:                ; tabela para as cores dos semáforos (VERDE, CINZENTO ou VERMELHO).
								   ; Por omissão, todos os semáforos são mostrados inicialmente a VERDE
     STRING    SEM_VERDE           ; cor do semáforo 0
     STRING    SEM_VERDE           ; cor do semáforo 1
     STRING    SEM_VERDE           ; cor do semáforo 2
     STRING    SEM_VERDE           ; cor do semáforo 3
     STRING    SEM_VERDE           ; cor do semáforo 4
     STRING    SEM_VERDE           ; cor do semáforo 5
     STRING    SEM_VERDE           ; cor do semáforo 6
     STRING    SEM_VERDE           ; cor do semáforo 7

cores_semaforos_89:
	 STRING    SEM_CINZENTO     ; cor do semáforo 8
     STRING    SEM_CINZENTO        ; cor do semáforo 9
; **********************************************************************
; * Código
; **********************************************************************
PLACE     0
inicio:
	MOV SP,SP_inicial						; inicializa o stack pointer
;**********************************************
;Inicializa_comboios
;Inicia os comboios a velocidade maxima
;**********************************************	

	 PUSH R0
	 PUSH R1
	 PUSH R2
	 MOV R0, VEL_MAX
	 MOV R1, COMBOIO_0
	 SHL R1,4
	 MOV R2, SELECAO
	 MOVB [R2], R1
	 MOV R2,COMANDO
	 MOVB [R2], R0

	 MOV R0, VEL_MAX
	 MOV R1, COMBOIO_1
	 SHL R1,4
     MOV R2, SELECAO
	 MOVB [R2], R1
	 MOV R2,COMANDO
	 MOVB [R2], R0
	 
	 POP R2
	 POP R1
	 POP R0

;**********************************************
;Inicializa os semaforos de 0 a 7
;**********************************************	
inicia_interface_semaforos_07:			; inicializa a cor dos semaforos 0 a 7 de acordo com a tabela presente na memoria
	 PUSH R0								; guarda valores dos registos na pilha
	 PUSH R1
	 PUSH R2
	 PUSH R3
	 PUSH R4
	 PUSH R5
	 MOV  R0,SEMAFOROS			; endereço do porto dos semáforos no módulo dos comboios
	 MOV R2, 0
	 MOV R1,cores_semaforos_07 	; endereço da tabela das cores dos vários semáforos entre 0 e 7
ciclo_semaforos_07:
	 MOV R5, 7
	 CMP R2,R5					; verifica se já foram inicializados todos os semaforos entre 0 e 7
	 JZ fim_ciclo_07			; se todos os semáforos já foram inicializados a interface está pronta para as funçoes respetivas aos semaforos	
	 MOV R5,R1					; endereço da tabela das cores dos vários semáforos entre 0 e 7
	 ADD R5, R2					; obtém endereço do byte de cor do semáforo (soma o número do semáforo à base da tabela)
	 MOVB R3,[R5]				; lê a cor do semaforo (o numero do semaforo é dado por R2 que serve de iterador)
	 MOV R4,R2					; permite não alterar o iterador
	 SHL R4,2					; formato do porto dos semáforos 0 a 7(número do semáforo tem de estar nos bits 7 a 2, cor nos bits 1 e 0)
	 ADD R4,R3					; junta cor do semáforo (que fica nos bits 1 e 0)
	 MOVB [R0], R4				; atualiza cor no semaforo propriamente dito
	 ADD R2,1					; permite ler a cor de todos os semaforos (R2 tem o numero do semaforo que queremos atualizar)
	 JMP ciclo_semaforos_07		; vai ler a cor do proximo semaforo e atualizar na interface
fim_ciclo_07:
	 POP R5						; repõe os valores anteriores dos registos a partir das cópias guardadas na pilha
	 POP R4
	 POP R3
	 POP R2
	 POP R1
	 POP R0

;**********************************************
;Inicializa os semaforos de 8 a 9
;**********************************************	

inicio_interface_semaforos_89:	; inicializa a cor dos semaforos 8 e 9 de acordo com a tabela presente na memoria
	 PUSH R0						; guarda valores dos registos na pilha
	 PUSH R1
	 PUSH R2
	 PUSH R3
	 PUSH R4
	 PUSH R5
	 MOV R0, SEMAFOROS_PN				; endereço do porto dos semáforos de passagem de nível no módulo dos comboios
	 MOV R2, 0
	 MOV R1,cores_semaforos_89			; endereço da tabela das cores dos vários semáforos 8 e 9
ciclo_semaforos_89:
	MOV R5, 2
	 CMP R2,R5							; verifica se já foram inicializados os semaforos 8 e 9
	 JZ fim_ciclo_89					; se todos os semáforos já foram inicializados a interface está pronta para as funçoes respetivas aos semaforos	
	MOV R5,R1							; endereço da tabela das cores dos vários semáforos 8 e 9
	 ADD R5,R2							; obtém endereço do byte de cor do semáforo (soma o número do semáforo à base da tabela)
	 MOVB R3,[R5]						; lê a cor do semaforo (o numero do semaforo é dado por R2 que serve de iterador)
	 MOV R4,R2							; permite não alterar o iterador
	 SHL R4,1							; formato do porto dos semáforos de passagem de nível(número do semáforo tem de estar nos bits 7 a 1, cor no bit 0)
	 ADD R4,R3							; junta cor do semáforo (que fica nos bit 0)
	 MOVB [R0], R4						; atualiza cor no semaforo propriamente dito
	 ADD R2,1							; permite ler a cor de todos os semaforos (R2 tem o numero do semaforo que queremos atualizar)
	 JMP ciclo_semaforos_89				; vai ler a cor do proximo semaforo e atualizar na interface
fim_ciclo_89:
	 POP R5								; repõe os valores anteriores dos registos a partir das cópias guardadas na pilha
	 POP R4
	 POP R3
	 POP R2
	 POP R1
	 POP R0
	 
	 MOV R0, 0				
	 MOV R1, 0
	 MOV R2, 0
	
	MOV BTE, TABELA_INTERRUPCOES			
	MOV R0,2					
	MOV RCN,R0
	EI0
	EI1
	EI

;**********************************************
;Funcao principal
;**********************************************		
programa:
	CALL inicio_agulhas
	MOV R0, 0
	CALL Maquinista
	MOV R0, 1
	CALL Maquinista
	CALL Pisca_semaforos_pn
	JMP programa
;**********************************************
;Rotina de tratamento da Interrupção 0 ((eventos de passagem pelos sensores))
;Descricao: Esta rotina ocorre sempre que existir um evento de sensores para ler.
;A rotina obtem o comboio que esta a passar pelo sensor, assim como o sensor por
;que este passa, armazenando estas informacoes em memoria.
;**********************************************		
rot0:
	PUSH R0						; guarda valores dos registos na pilha
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	MOV R0,SENSOR_INFO			; acede a sensor_lido
	MOVB R1,[R0]				; lê 1º byte (informação sobre o comboio que passou)
	MOVB R2,[R0]				; lê 2º byte (número do sensor)
	BIT R1, 0					; verifica qual foi a parte do comboio que passou pelo sensor
	JNZ rot0_fim				; ignora a passagem da parte de tras do comboio
	SHR R1,1					; coloca a informacao relativa ao numero do comboio no primeiro bit
	MOV R0,sensor_lido			; acede a sensor_lido
	ADD R0, R1					; guarda em memoria o numero do sensor lido
	MOVB [R0],R2				; guarda em memoria o numero do sensor lido
rot0_fim:
	POP R4
	POP R3
	POP R2
	POP R1
	POP R0
	RFE
;*******************************************************************************************
;Rotina de tratamento da Interrupção 1 (ciclo de relogio)
;Esta rotina recebe os ciclos de relogio e incrementa tres contadores dependente de tres
;variaveis guardadas guardadas em memoria
;*******************************************************************************************
rot1:
	 PUSH R9					  ; guarda valores dos registos na pilha
	 PUSH R10
cont0:
	 MOV R9, ligacont0			  ; variavel que indica se existe algum comboio parado na estacao 1
	 MOVB R10, [R9]
	 CMP R10,1
	 JNZ cont1					  ; caso o valor de ligacont0 seja 1, é necessário ativar o contador0 uma vez que ha um comboio parado na estacao 1
	 MOV R9, contador0
	MOVB R10,[R9]
	 ADD R10,1					  ; incrementa contador0 em uma unidade em cada ciclo de relogio
	MOVB [R9],R10
cont1:
	 MOV R9, ligacont1			  ; variavel que indica se existe algum comboio parado na estacao 2
	 MOVB R10, [R9]
	 CMP R10,1
	 JNZ cont2				  	  ; caso o valor de ligacont1 seja 1, é necessário ativar o contador1 uma vez que ha um comboio parado na estacao 2
	 MOV R9, contador1
	MOVB R10,[R9]
	 ADD R10,1					  ; incrementa contador1 em uma unidade em cada ciclo de relogio
	MOVB [R9],R10
cont2:
	 MOV R9, ligacont2			  ; variavel que indica se existe algum comboio a passar pela passagem de nivel
	 MOVB R10, [R9]
	 CMP R10,1				
	 JNZ fim_rot1				  ; caso o valor de ligacont2 seja 1, é necessário ativar o contador2 uma vez que ha um comboio a passar na passagem de nivel
	 MOV R9, contador2
	MOVB R10,[R9]
	 ADD R10,1					  ; incrementa contador2 em uma unidade em cada ciclo de relogio
	MOVB [R9],R10
	JMP fim_rot1
fim_rot1:
	 POP R10
	 POP R9
	 RFE 

	 
; **********************************************************************
; * Maquinista
; * Descricao: Controla o movimento dos comboios
; * Recebe: R0 -> numero do comboio a analisar
; * Retorna: Nada 
; **********************************************************************
Maquinista:
	PUSH  R0					  ; guarda valores dos registos na pilha
	PUSH  R1
	PUSH  R2
	PUSH  R3
	PUSH  R4
	MOV   R1,velocidade_comboios  ; vai buscar o endereco onde estao armazenadas as velocidades dos comboios
	ADD   R1,R0					  ; vai ser analisada a velocidade do comboio 0
	MOVB  R2,[R1]
	CMP   R2,VEL_NULA			  ; analisa se o comboio esta parado
	JZ    Maquinista_parado		  ; caso o comboio esteja parado, vai verificar local onde esta parado (semaforo ou estacao)
Maquinista_movimento:
	CALL obtem_sensor			  ; caso o comboio esteja em movimento vai ser analisado se o comboio analisado passou por um sensor
	MOV R3, NAO_HA_EVENTO         ; ve se o comboio passou por algum sensor
	CMP R1, R3
	JZ fim_maquinista			  ; caso o comboio esteja parado saltar para o fim da rotina de sensores
	CMP R1,2H					  ; caso o comboio tenha passado por algum sensor, verifica-se se este passou pelo sensor 2 (estacao B)
	JZ estacao_Aa				  ; caso o comboio tenha passado pelo sensor 2, este vai parar uma vez que se localiza numa estacao  
	CMP R1,5H					  ; verifica-se se o comboio passou pelo sensor 5 (estacao A)
	JZ estacao_Bb				  ; caso o comboio tenha passado pelo sensor 5, este vai parar uma vez que se localiza numa estacao 
	MOV R2,08H					  ; verifica-se se o comboio passou pelo sensor 8 (passagem de nivel)
	CMP R1,R2
	JGE passagem_nivel			  ; caso o sensor pelo qual o comboio passou for superior a 8, o comboio passou pela passagem de nivel
	JMP continuacao
estacao_Aa:						  ; trata o caso do comboio ter entrado na estacao A
	CALL estacao_A				  ; chama a rotina que inicializa o contador referente à estacao A (contador0)
	CALL altera_velocidade		  ; chama a rotina que vai parar o comboio
	MOV R2,trocos_ocupados		  ; a excessão de paragem em estacao vai ser tratada. Acede-se ao endereco onde estao guardados os trocos ocupados
	ADD R2,R0					  ; acede-se a posicao da tabela trocos_ocupados onde se localiza o troco ocupado pelo comboio analisado
	MOV R1, 2H					  ; reserva o troco da estacao A para o comboio analisado
	MOVB [R2], R1
	JMP fim_maquinista			  ; visto que o comboio analisado parou na estacao A, nao e possivel ocorrer nenhum dos restantes casos
estacao_Bb:						  ; trata o caso do comboio ter entrado na estacao B
	CALL estacao_B				  ; chama a rotina que inicializa o contador referente à estacao B (contador1)
	CALL altera_velocidade		  ; chama a rotina que vai parar o comboio
	MOV R2,trocos_ocupados		  ; a excessão de paragem em estacao vai ser tratada. Acede-se ao endereco onde estao guardados os trocos ocupados
	ADD R2,R0					  ; acede-se a posicao da tabela trocos_ocupados onde se localiza o troco ocupado pelo comboio analisado
	MOV R1,5					  ; reserva o troco da estacao A para o comboio analisado
	MOVB [R2], R1
	JMP fim_maquinista			  ; visto que o comboio analisado parou na estacao A, nao e possivel ocorrer nenhum dos restantes casos
passagem_nivel:					  ; trata o caso do comboio estar na zona de passagem de nivel
	CMP R1,R2					  ; verifica se o comboio passou pelo sensor 8 (compara com o valor em R2 -> 08H)
	JNZ passagem_nivel_f		  ; caso o comboio nao tenha passado pelo sensor 9, este passou 
passagem_nivel_i:				  ; analisa o caso do o comboio ter entrado na zona de paragem de niveis
	MOV R8,0					  ; vai-se iniciar o semaforo 8 a vermelho
	CALL inicio_semaforos_89	  ; chama-se a rotina relativa aos semaforos 8 e 9 para mudar a cor do semaforo indicado por R8
	CALL passagem_nivel_8		  ; chama a rotina que inicia o contador 1 
	MOV R2,trocos_ocupados		  ; acede ao endereco onde estao guardados os trocos ocupados pelos comboios 
	ADD R2,R0					  ; vai-se aceder a posicao da tabela trocos_ocupados onde esta guardado o troco ocupado pelo comboio analisado
	MOV R3,6					  ; reserva-se o troco seis (proximo troco com semaforos) para o comboio analisado
	MOVB [R2],R3	
	JMP fim_maquinista			  ; visto que o comboio analisado esta na zona de passagem de nivel, nao e possivel ocorrer nenhum dos restantes casos
passagem_nivel_f:				  ; analisa o caso do o comboio ter entrado na zona de paragem de niveis
	 CALL passagem_nivel_9		  ; chama a rotina que inicializa o contador 2
	 MOV R8,0
     MOV  R4, cores_semaforos_89     ; endereço da tabela das cores dos  semáforos 8 e 9
     ADD  R4, R8                     ; obtém endereço do byte de cor do semáforo (soma o número do semáforo à base da tabela)
     MOVB R3, [R4]                   ; lê a cor do semáforo
	 CMP R3, SEM_CINZENTO			 ; verifica se o semaforo 8 esta a cinzento
	 JNZ analisa_sem9				 ; caso o semaforo ja esteja a cinzento, meter o semaforo 9 a cinzento
	 CALL inicio_semaforos_89		 ; rotina que mete o semaforo 8 a cinzento
	 JMP mudou_sinal
	analisa_sem9:					 ;mete o semaforo 9 a cinzento
	 MOV R8,1
	 CALL inicio_semaforos_89
	mudou_sinal:
	 JMP fim_maquinista
continuacao:
	CALL obtem_troco_seguinte		; chama a rotina que obtem o troco seguinte
	CALL ultimo_troco_outro_comboio ; chama a rotina que obtem o troco onde esta o comboio
	CMP R2,R3 						; compara o troço seguinte (guardado em R3) com o ultimo troço ocupado pelo outro comboio (guardado em R2)
	JNZ altera_troco				; caso sejam diferentes muda os sinais e reserva o troco seguinte para o comboio analisado
	CALL altera_velocidade		    ; muda a velocidade do comboio
	JMP fim_maquinista
altera_troco:
	CALL altera_cor_semaforos		; chama a rotina que altera o semaforo dependente do troco reservado
	CALL altera_ultimo_troco		; chama a rotina que altera o troco onde se localiza o comboio 
	MOV R2, sensores_ciclo_anterior ; acede ao endereco da tabela onde estao guardados os sensores lidos no ciclo anterior
	ADD R2,R0						; acede a posicao da tabela referente ao comboio analisado
	MOVB [R2],R1					; guarda na posicao acedida o sensor lido nesta ciclo 
	JMP fim_maquinista
Maquinista_parado:
	MOV R2,trocos_ocupados			; acedo ao endereco da tabela onde estao guardados os trocos ocupados pelos comboios
	ADD R2,R0						; acede a posicao referente ao comboio analisado
	MOVB R1,[R2] 					; descobre o troco onde o comboio esta parado 
	CMP R1,2						; verifica se o comboio esta numa estacao
	JZ parado_em_A
	CMP R1,5
	JZ parado_em_B
	CALL obtem_troco_seguinte		; obtem em R3 o troço seguinte do comboio parado
	CALL ultimo_troco_outro_comboio ; chama a rotina que analisa o ultimo troco pelo qual o outro comboio passou
	CMP R2,R3						; caso os trocos sejam iguais nao faz nada
	JZ fim_maquinista
	CALL altera_velocidade			; caso os trocos sejam diferentes, meter o comboio a andar
	CALL altera_ultimo_troco		; altera o valor do ultimo troco pelo qual o comboio passou
	JMP fim_maquinista	
parado_em_A:						; analisa o caso do comboio estar parado na estacao A
	MOV R2, contador1
	MOVB R3,[R2]					; mete em R3 o valor actual do contador
	MOV R2,incontador1				
	MOV R4, [R2]					; coloca em R4 o valor inicial do contador
	ADD R4,6
	CMP R3,R4						; caso ja se tenho realizados seis ciclos o comboio deve comecar a andar
	JNZ fim_maquinista
	CALL altera_velocidade
    MOV R2, ligacont1				; desliga o interruptor do contador1
	MOV R3, 0
	MOVB [R2], R3
	MOV R2,contador1				; reinicia o contador1
	MOVB [R2],R3
	MOV R2,trocos_ocupados			
	MOV R3, 7						; reserva o troco 7 para o comboio analisado 
	ADD R2,R0
	MOVB [R2], R3			
	JMP fim_maquinista
parado_em_B:						; analisa o caso do comboio estar parado na estacao B
	MOV R2,contador0
	MOVB R3,[R2]					; mete em R3 o valor actual do contador
	MOV R2, incontador0
	MOVb R4,[R2]					; coloca em R4 o valor inicial do contador
	ADD R4,6
	CMP R3,R4						; caso ja se tenho realizados seis ciclos o comboio deve comecar a andar
	JNZ fim_maquinista
	CALL altera_velocidade
	MOV R2, ligacont0				; desliga o interruptor do contador0
	MOV R3, 0
	MOVB [R2], R3
	MOV R2,contador0				; reinicia o contador0
	MOVB [R2],R3
	MOV R2,trocos_ocupados
	MOV R3, 0						; reserva o troco 0 para o comboio analisado 
	ADD R2,R0
	MOVB [R2], R3
	JMP fim_maquinista
fim_maquinista:
	POP   R4
	POP   R3
	POP   R2
	POP   R1
	POP   R0
	RET

; **********************************************************************
; * Rotina dos sensores
; * Descricao: Esta rotina obtem o sensor guardado em memoria para o comboio analisado
; * Argumentos : numero do comboio (R0) 
; * Retorna: numero do sensor (R1) numero do comboio (R0)
; **********************************************************************

obtem_sensor: 
	PUSH R0
    PUSH R2
	PUSH R3
	PUSH R4
	MOV R2, sensor_lido				; acede a tabela de sensor_lido
	ADD R2,R0						; acede a posicao da tabela sensor_lido referente ao comboio analisado
	MOVB R1,[R2]
	MOV R4,NAO_HA_EVENTO
	CMP R1,R4						; caso nao haja eventos, saltar para o fim da rotina
	JZ sensores_fim
	MOVB [R2], R4					; reinicia o valor na tabela sensor_lido
sensores_fim:
	POP R4
	POP R3
    POP R2
	POP R0
    RET
	
; **********************************************************************
; * Rotina da passagem_nivel_8
; * Descricao: Esta rotina liga o contador 2
; * Argumentos : Nenhum
; * Retorna: Nada
; **********************************************************************
	
passagem_nivel_8:
	PUSH R8
	PUSH R9
	PUSH R10
	MOV R9, ligacont2				; liga interruptor relativo ao contador 2
	MOV R10, 1
    MOVB [R9], R10
	MOV R9, contador2
	MOVB R8, [R9]
	MOV R9, incontador2				; guarda em memoria (incontador2) o valor inicial do contador 2
	MOVB [R9], R8
	POP R10
	POP R9
	POP R8
	RET
	
; **********************************************************************
; * Rotina da passagem_nivel_9
; * Descricao: Esta rotina liga o contador 2
; * Argumentos : Nenhum
; * Retorna: Nada
; **********************************************************************
	
passagem_nivel_9:	
	PUSH R8
	PUSH R9
	PUSH R10
	MOV R9, ligacont2				; liga interruptor relativo ao contador 2
	MOV R10, 0
	MOVB [R9], R10
	MOV R9, contador2				; guarda em memoria (incontador2) o valor inicial do contador 2
	MOV R8,0
	MOVB [R9], R8 
	POP R10
	POP R9
	POP R8
	RET

; *********************************************************************
;  Processo para obter o troço seguinte a um sensor
; Descricao: Esta rotina obtem o troco seguinte ao sensor dado em R1
; * Argumentos : numero do sensor(R1)
; * Retorna : numero do troço seguinte (R3)
;
; *********************************************************************	
	
obtem_troco_seguinte:
    PUSH R2
	PUSH R4
	PUSH R5
	MOV R2, trocos_seguintes 			; acede a tabela que indica os trocos seguintes aos sensores
	CMP R1, 2							; caso o sensor lido for um maior que 2, entao trata-se dum caso em que nao existe interacao com agulhas
	JGE trocos_normais					; salta para trocos_normais caso nao seja necessario analisar agulhas
	CMP R1,1							; verifica se o sensor lido é o 1 
	JZ sensor_1
sensor_0:
	MOV R3,direcao_agulhas				; acede a tabela das agulhas
	MOVB R4,[R3]
	MOV R5,AGU_DIR
	CMP R4,R5							; verifica o estado da agulha 0 
	JZ ocupa_troco_4					; caso a agulha esteja para a direita, ocupar troco 4
	ADD R3,2							; verificar estado da agulha 2
	MOVB R4,[R3]						
	MOV R5,AGU_DIR
	CMP R4,R5
	JZ ocupa_troco_3					; caso a agulha esteja para a direita, ocupar o troco 3
ocupa_troco_8:							; reserva troco 8
	MOV R3,08H
	JMP fim_obtem_troco_seguinte
ocupa_troco_3:							; reserva troco 3
	MOV R3,3
	JMP fim_obtem_troco_seguinte
ocupa_troco_4:							; reserva troco 4
	MOV R3,4
	JMP fim_obtem_troco_seguinte
sensor_1:								;analisa caso do comboio ter passado por 1
	MOV R3, direcao_agulhas
	ADD R3,2
	MOVB R4,[R3]
	MOV R5,AGU_DIR
	CMP R4,R5
	JZ ocupa_troco_3					; verifica o estado da agulha 2. Caso esta esteja para a direita ocupar troco 3
	JMP ocupa_troco_8					; caso contrario ocupar troco 8
trocos_normais:							; analisa casos do comboio passar por um sensor superior a 2
	ADD R2,R1
	MOVB R3,[R2] 
fim_obtem_troco_seguinte:
	POP R5
	POP R4
	POP R2
	RET
	
; *********************************************************************
;  Processo para obter o ultimo troco do outro comboio
; Descricao: Esta rotina obtem o troco seguinte ao sensor dado em R1
; * Recebe: R0-> numero do comboio
; * Retorna : Nada
;
; *********************************************************************	

	
ultimo_troco_outro_comboio:			
	PUSH R0
	PUSH R1
	MOV R1,trocos_ocupados					; acede a tabela trocos_ocupados
	CMP R0,0								; verifica numero do comboio
	JNZ tratar_comboio_1					; analisa o outro comboio
tratar_comboio_0:
	ADD R0,1
	ADD R1,R0
	MOVB R2,[R1]
	JMP fim_ultimo_troco_outro_comboio
tratar_comboio_1:
	MOVB R2,[R1]
fim_ultimo_troco_outro_comboio:
	POP R1
	POP R0
	RET

; *********************************************************************
;  Processo de alteracao do ultimo troco
; Descricao: Esta rotina obtem o troco seguinte ao sensor dado em R1
; * Argumentos: R0 -> Numero do comboio; R3 ->  troco ocupado 
; * Retorna : Nada
; *********************************************************************	
	
	
altera_ultimo_troco:
	PUSH R1
	PUSH R2
	MOV R2,trocos_ocupados				; acede a tabela dos trocos ocupados
	ADD R2, R0							; acede a posicao da tabela referente ao comboio analisado
	MOVB [R2], R3						; guarda na tabela o troco em R3
	POP R2
	POP R1
	RET
	
	
; ***************************************************************************************
; 							Altera velocidade dos comboios
;
; Descrição : Altera a velocidade do comboio para a velocidade oposta
;
; Recebe : Número do comboio (R0)	
;
; Retorna : Nada
;
; ***************************************************************************************
	

altera_velocidade: 
	PUSH R0			
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	MOV R3,SELECAO				; endereço do porto de seleção de comboio e comando	
	MOV R4,COMANDO				; endereço do porto onde dar comandos para os comboios
	MOV R1,velocidade_comboios		;endereço da tabela que contem a velocidade dos comboios
	ADD R1,R0						; adiciona á base da tabela o numero do comboio para obter a velocidade desse comboio
	SHL R0, 4						; formato do porto de seleção 						
	MOVB R2,[R1]					; obtem a velocidade do comboio (R0) em R2
	MOV R5, VEL_MAX					
	CMP R2,R5						
	JZ para_comboio					; se o comboio estiver a andar vai parar
avanca_comboio:
	MOV R2, VEL_MAX					; caso contrario vai arrancar	
	JMP alteracao_velocidade
para_comboio:
	MOV R2,VEL_NULA					
alteracao_velocidade:
	MOVB [R3], R0					; numero do comboio 
	MOVB [R4], R2					; altera a velocidade do comboio propriamente dita
	MOVB [R1], R2					; atualiza a tabela de velocidades dos comboios
fim_velocidades:
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	POP R0
	RET
	
; **************************************************************************************
;	                          Altera Cor dos SEMAFOROS
;
; Descrição : Altera a cor dos semaforos consoante o sensor lido
;																
; Recebe : Número do sensor lido no ciclo atual
;
; Retorna : Nada
;
; **************************************************************************************
	
altera_cor_semaforos: 
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	MOV R3, SEMAFOROS					; endereço do porto dos semaforos						;
testa_sensor_0:
	CMP R1,0							;verifica se o semaforo a alterar é o 0
	JNZ testa_sensor_1					              
	MOV R4,direcao_agulhas          	;o numero do semaforo que tem de mudar de cor depende do estado das agulhas	
	MOVB R2,[R4]
	MOV R4, AGU_DIR
	CMP R4,R2							; se a agulha 0 estiver para a direita não alteramosa a cor  semaforo 0
	JZ testa_sensor_1
	MOV R2, SEM_VERMELHO			
	MOV R4,1
	SHL R4,2							; formato do porto dos semaforos
	ADD R4,R2
	MOVB [R3], R4							; caso contrario pomos o semaforo 0 a vermelho
	JMP casos_normais						; analisa os semaforos normais que não dependem das agulhas nem mudam mais que um semaforo
testa_sensor_1:
	CMP R1,1							;verifica se o semaforo a alterar é o 1
	JNZ testa_sensor_3
	MOV R4,direcao_agulhas				;o numero do semaforo que tem de mudar de cor depende do estado das agulhas	
	MOVB R2,[R4]
	MOV R4, AGU_DIR
	CMP R4,R2               
	JZ testa_sensor_3					; se a agulha 0 estiver para a direita não alteramosa a cor  semaforo 0
	MOV R2,SEM_VERMELHO
	MOV R4,0
	SHL R4,2
	ADD R4,R2
	MOVB [R3], R4						; caso contrario pomos o semaforo 0 a vermelho
	JMP casos_normais				 ; analisa os semaforos normais que não dependem das agulhas nem mudam mais que um semaforo
testa_sensor_3:						
	CMP R1,3							;verifica se o semaforo a alterar é o 3
	JNZ testa_sensor_4
	MOV R2,SEM_VERDE
	MOV R4,1
	SHL R4,2
	ADD R4,R2
	MOVB [R3], R4						; o semaforo 1 fica a verde		
	MOV R2,SEM_VERMELHO					
	MOV R4,4
	SHL R4,2
	ADD R4,R2
	MOVB [R3], R4						; o semaforo 4 fica a vermelho
	CALL ultimo_troco_outro_comboio		; calcula o ultimo troço do outro comboio
	CMP R2,4
	JZ testou_sensor_3			; se for 0 4 não alteramos o semaforo 0
	MOV R2,SEM_VERDE
	MOV R4,0
	SHL R4,2
	ADD R4,R2
	MOVB [R3], R4			; caso contrario metemos o semaforo 0 a verde
testou_sensor_3:
	JMP casos_normais
testa_sensor_4:
	CMP R1,4			;verifica se  o semaforo a alterar é o 4
	JNZ testa_sensor_5
	MOV R2,SEM_VERMELHO
	MOV R4,3
	SHL R4,2
	ADD R4,R2
	MOVB [R3],R4			;se o semaforo a alterar seja o 4 a cor do 3 tambem altera para vermelho
	JMP casos_normais
testa_sensor_5:
	CMP R1,5			;verifica se o semaforo a alterar é o 5
	JNZ testa_sensor_8
	MOV R2,SEM_VERDE
	MOV R4,3
	SHL R4,2
	ADD R4,R2
	MOVB [R3], R4 		; se o semaforo a alterar for o 5 poe o 3 a verde
	JMP casos_normais
testa_sensor_8:
	MOV R2,8				;verifica se o semaforo a alterar é o 8
	CMP R1,R2
	JNZ casos_normais
	CALL ultimo_troco_outro_comboio			; se for o 8 calculamos o ultimo troço do outro comboio
	CMP R2,4						; se o outro comboio estiver no troço 4 nao alteramos a cor do semaforo 0
	JZ casos_normais
	MOV R2,SEM_VERDE
	MOV R4,0
	SHL R4,2
	ADD R4,R2
	MOVB [R3], R4				;caso contrario poe o semaforo 0 a verde
casos_normais:
	MOV R3, SEMAFOROS			;endereço do porto dos semaforos
poe_atual_a_vermelho:
	MOV R2,SEM_VERMELHO
	SHL R1,2
	ADD R1,R2
	MOVB [R3], R1				; o semaforo correspondente ao numero do sensor lido fica a vermelho
poe_anterior_a_verde:
	MOV R2, sensores_ciclo_anterior
	ADD R2,R0
	MOVB R1,[R2]
	MOV R2,SEM_VERDE
	SHL R1,2
	ADD R1,R2
	MOVB [R3],R1			; o semaforo anterior ao lido fica a verde (calculamos atraves do sensor lido no ciclo anterior que está na memoria)
fim_altera_semaforos:
	POP R4
	POP R3
	POP R2
	POP R1
	POP R0
	RET
	
; ***************************************************************************
;							Estaçao A
;
; Descrição : Inicia o contador 1 quando um comboio para na estação A
;
; Recebe : Nenhum
;
; Retorna : Nada
;
; **************************************************************************
	
estacao_A:
	PUSH R0						 ; guarda valor dos registos na pilha	
	PUSH R3
	PUSH R8
	PUSH R9
	PUSH R10
	MOV R9, ligacont1			
	MOV R10, 1		
	MOVB [R9], R10				; liga o interruptor do contador 1
	MOV R9, contador1
	MOVB R8, [R9]
	MOV R9, incontador1
	MOVB [R9], R8			 	; guarda o valor do contador 1 em memoria
	POP R10					    ; repõe os valores anteriores dos registos a partir das cópias guardadas na pilha
	POP R9
	POP R8
	POP R3
	POP R0
	RET
	
; ***************************************************************************
;							Estaçao B
;
; Descrição : Inicia o contador 0 quando um comboio para na estação B
;
; Recebe : Nenhum
;
; Retorna : Nada
;
; **************************************************************************
	
estacao_B:
	PUSH R0					 ; guarda valor dos registos na pilha	
	PUSH R3
	PUSH R8
	PUSH R9
	PUSH R10
	MOV R9, ligacont0 
	MOV R10, 1
	MOVB [R9], R10			; liga o interruptor do contador 0
	MOV R9, contador0
	MOVB R8, [R9]
	MOV R9, incontador0
	MOVB [R9], R8			; guarda o valor do contador 0 em memoria
	POP R10					; repõe os valores anteriores dos registos a partir das cópias guardadas na pilha
	POP R9
	POP R8
	POP R3
	POP R0
	RET
	
; **********************************************************************
;                        Rotina das agulhas
;
; * Descrição: Lê os botões de pressã (0 a 3) 
;
; * Recebe : Nenhum
;
; * Retorna : Nada
;
; **********************************************************************	 
inicio_agulhas:
	 PUSH R0 			          ; guarda valor dos registos na pilha											 
	 PUSH R1
	 PUSH R2
	 PUSH R3
	 PUSH R6
	 MOV R0,0					   ; permite ter um R0 nao alterado pelo numero do comboio (fornecido na função principal como argumento)
     MOV R2, BOTOES_PRESSAO        ; endereço do porto dos botoes de pressão
	
botoes_carregados:
	 MOVB R1, [R2]                 ; lê o estado dos botões (modo byte, periférico 8 bits)
le_botoes:                         ; obtem o numero do botao pressionado caso existir (em R0)
	 BIT R1,0                      ; testa os varios botoes de pressão  
	 JNZ testa_a_direcao           ; se o botao estiver a ser pressionado vai mudar a direção da agulha correspondente (a R0)
	 CMP R0, 3                     ; verifica se já foram testados todos os botoes
	 JZ  nenhum_botao_ativo        ; apos a verificação se nenhum botao está carregado inicia a preparaçao do novo ciclo
	 SHR R1,1                      ; permite ler todos os botões de pressão
	 ADD R0,1                      ; guarda o numero do botao que esta a ser carregado (em R0)
	 JMP le_botoes                 ; le o proximo botao de pressão 0 a 3
	
nenhum_botao_ativo:				; caso nenhum botão esteja ativo então será gravado um valor que não representa nenhuma agulha 
	 MOV R0,0FH
	 JMP fim_agulhas
	
testa_a_direcao:
	 MOV R3, agulha_escolhida	;vai buscar à memória a ultima agulha que foi alterada
	 MOVB R6,[R3]               
	 CMP  R0, R6				; verifica se número da agulha alterada no ciclo anterior é igual ao número da agulha deste ciclo
	 JZ   fim_agulhas			; se forem iguais não alteramos o estado da agulha (assim não muda continuamente quando o botão é primido)
	 CALL obtem_direcao_agulha	
	 CMP  R3, AGU_ESQ
     JZ   poe_dir               ; se a agulha esta virada para a esquerda, troca a direção para a direita, caso contrário põe virada para a esquerda
     
poe_esq:
     MOV  R3, AGU_ESQ           ; direção vai ficar para a esquerda
     JMP  atualiza_direcao
     
poe_dir:
     MOV  R3, AGU_DIR         ; direção vai ficar para a direita
	
atualiza_direcao:
     CALL atualiza_direcao_agulha		; R0 ainda tem o número da agulha e R3 tem a direção nova
                                   
								   
fim_agulhas:
	 MOV R3,agulha_escolhida	   
	MOVB [R3],R0				   ; guarda em agulha_escolhida o numero da ultima agulha mudada
	 POP R6						   ; repõe os valores anteriores dos registos a partir das cópias guardadas na pilha
	 POP R3
	 POP R2
	 POP R1
	 POP R0
	 RET     					   ; volta à rotina principal
	 
;  ***********************************************************************************************
;                          Obtem direção agulhas
;
; * Descrição : Obtem o  estado da agulha que queremos alterar  lendo o seu estado da memória
;
; * Recebe : numero da agulha tratada neste ciclo (R0) 
;
; * Retorna : estado da agulha 
;
; **************************************************************************************************
	
obtem_direcao_agulha:
	 PUSH R4                    ; guarda valor do registo na pilha
     MOV  R4, direcao_agulhas   ; endereço da tabela das direções das agulhas 
     ADD  R4, R0                ; obtém endereço do byte da direção da agulha (soma o número da agulha à base da tabela)
     MOVB R3, [R4]              ; lê a direção da agulha
     POP R4                     ; repõe o valor anterior do registo a partir da cópia guardada na pilha
	 RET

; *****************************************************************************************************
;								Atualiza direção da agulha
;
; * Descrição : Altera o estado da agulha
;
; * Recebe : numero da agulha a alterar (R0) e a nova direção (R3)
;
; * Retorna : Nada
;
;******************************************************************************************************

atualiza_direcao_agulha:
     PUSH R9                    ; guarda valores dos registos na pilha
     PUSH R10
     PUSH R11
	 MOV  R9,R0                   ; faz com que o R0 não seja alterado nesta rotina
     MOV  R10, direcao_agulhas    ; endereço da tabela das direções das agulhas
     ADD  R10, R9                 ; obtém endereço do byte da direção da agulha (soma o número da agulha à base da tabela)
     MOVB [R10], R3               ; atualiza a direção das agulhas na tabela de direções das agulhas
	 SHL  R9, 2                   ; formato do porto das agulhas (número da agulha tem de estar nos bits 7 a 2, cor nos bits 1 e 0)
     ADD  R9, R3                  ; junta direção das agulhas (que fica nos bits 1 e 0)
     MOV  R11, AGULHAS            ; endereço do porto das agulhas 
     MOVB [R11], R9               ; atualiza a direção da agulha propriamente dita
     POP R11                      ; repõe os valores anteriores dos registos a partir das cópias guardadas na pilha
     POP R10
     POP R9
	 RET
	 
; *****************************************************************************************************
;								Semaforos 8 e 9
;
; Descrição : Altera a cor dos semaforos 8 e 9
;
; Recebe : Numero do semaforo a ser alterado (R8)
;
; Retorna : Nada
;
; *****************************************************************************************************
	 
inicio_semaforos_89 :
	 PUSH R1					   ; guarda valores dos registos na pilha
	 PUSH R2
	 PUSH R3
	 PUSH R4 
	 PUSH R5
	 PUSH R7						
	 PUSH R8
	 PUSH R9
     PUSH R10
     PUSH R11
testa_a_cor_89:
	 CALL obtem_cor_semaforo_89		;obtem a cor do semaforo (correspondente a R8) em R3
	 MOV R11, SEM_CINZENTO	
	 CMP  R3, R11							
     JZ   poe_vermelho_PN           ; se o semáforo está a cinzento, põe a vermelho, caso contrário põe a cinzento
     
poe_cinzento:
     MOV  R3, SEM_CINZENTO            ; semáforo vai ficar cinzento
     JMP  atualiza_cor_89
     
poe_vermelho_PN:
     MOV  R3, SEM_VERMELHO         ; semáforo vai ficar vermelho
	
atualiza_cor_89:
     CALL atualiza_cor_semaforo_89   ; atualiza cor do semáforo na tabela e na interface.
                                     ; R8 ainda tem o número do semáforo e R3 tem a nova cor
	 JMP fim_semaforos_89
	 
;  ***********************************************************************************************
;                          Obtem cor semaforo 
;
; * Descrição : Obtem o  estado do semaforo que queremos alterar  lendo o seu estado da memória
;
; * Recebe : numero do semaforo tratado neste ciclo (R0) 
;
; * Retorna : estado do semaforo 
;
; **************************************************************************************************

obtem_cor_semaforo_89:
     MOV  R4, cores_semaforos_89     ; endereço da tabela das cores dos  semáforos 8 e 9
     ADD  R4, R8                     ; obtém endereço do byte de cor do semáforo (soma o número do semáforo à base da tabela)
     MOVB R3, [R4]                   ; lê a cor do semáforo
	 RET

; *****************************************************************************************************
;								Atualiza cor do semaforo 8 e 9
;
; * Descrição : Altera o estado do semaforo
;
; * Recebe : numero do semaforo a alterar (R0) e a nova cor (R3)
;
; * Retorna : Nada
;
;******************************************************************************************************

atualiza_cor_semaforo_89:
	 MOV R9,R8				          ; permite não alterar R8 nesta rotina
     MOV  R10, cores_semaforos_89     ; endereço da tabela das cores dos vários semáforos
     ADD  R10, R9                     ; obtém endereço do byte de cor do semáforo (soma o número do semáforo à base da tabela)
     MOVB	[R10], R3                 ; atualiza a cor do semáforo na tabela de cores dos semáforos 8 e 9
	 SHL  R9, 1                       ; formato do porto dos semáforos de passagem de nível(número do semáforo tem de estar nos bits 7 a 1, cor no bit 0)
     ADD  R9, R3                      ; junta cor do semáforo (que fica nos bits 1 e 0)
     MOV  R11, SEMAFOROS_PN           ; endereço do porto dos semáforos de passagem de nível no módulo dos comboios
     MOVB [R11], R9                   ; atualiza cor no semaforo propriamente dito
	 RET

fim_semaforos_89:
	 POP R11						 ;repõe os valores anteriores dos registos a partir das cópias guardadas na pilha
     POP R10
	 POP R9
	 POP R8				
	 POP R7
	 POP R5
	 POP R4
	 POP R3
	 POP R2
	 POP R1
	 RET 					; sai da rotina correspondente dos semaforos 8 e 9
	 
; ***********************************************************************************
;								Pisca semaforos da passgem de nivel
;
; Descrição: Quando um comboio se encontra entre o sensor 8 e o sensor 9, os semaforos de passagem de nivel alternam entre si
;
; Recebe : Nenhum
;
; Retorna : Nada
;
; ***********************************************************************************
	
Pisca_semaforos_pn:
	 PUSH R1			; guarda valores dos registos na pilha
	 PUSH R2
	 PUSH R8
	 PUSH R9
	 MOV R9, contador2		
	 MOVB R1, [R9]					; mete em R1 o valor do contador 2
	 MOV R9, incontador2
	 MOVB R2, [R9]					; mete em R2 o valor inicial do contador 2
	 CMP R1, R2
	 JZ fim_semaforos_pn			; caso sejam diferentes ocorreu um ciclo, os semaforos devem alterar de cor
	 MOVB [R9], R1					; faz reset ao contador inicial 
	 MOV R8,1						; altera a cor do semaforo 9
	 CALL inicio_semaforos_89
	 MOV R8,0						; altera a cor do semaforo 8
	 CALL inicio_semaforos_89
fim_semaforos_pn:
	 POP R9			 			;repõe os valores anteriores dos registos a partir das cópias guardadas na pilha
	 POP R8
	 POP R9
	 POP R1
	 RET