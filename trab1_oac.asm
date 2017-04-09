#-------------------------------------------------------------------------
#		Organização e Arquitetura de Computadores - Turma C 
#			Trabalho 1 - Programação Assembler
#
# Nome:  Eduardo Said Calil Vilaça		Matrícula: 13/0154253 
# Nome:  Lukas Ferreira Machado			Matrícula: 12/0127377
# Nome:  Raphael Luis Souza de Queiroz 	        Matrícula: 13/0154989

.data

image_name:   	    .asciiz "lenaeye.raw"   # nome da imagem a ser carregada
address: 	    .word   0x10040000	    # endereco do bitmap display na memoria
_mask: 	    	    .word   0x00000000	    # maskara para cor RGB	
_bmpDim:	    .word   63		    # Dimensao da matriz do bitmap (64 x 64), indexada de 0 a 63
buffer:		    .word   0		    # configuracao default do MARS
size:		    .word   4096            # numero de pixels da imagem

.text

j inicializa

.macro print_int (%x)
	li $v0, 1
	add $a0, $zero, %x
	syscall
.end_macro

.macro get_int
	li $v0, 5             # Pega a opção inserida
	syscall
.end_macro

.macro print_str (%str)
	.data
		myLabel: .asciiz %str
	.text
		li $v0, 4
		la $a0, myLabel
		syscall
.end_macro

# inicializa as variáveis globais
inicializa:
	lw $a1, address
  	la $a2, buffer
  	lw $a3, size

# Mostra o menu de opções principal
mostra_menu:
	print_str("\n\n")
	print_str("\tMenu Inicial")
	print_str("\n")

	print_str("1- Obtém ponto")
	print_str("\n")
	
	print_str("2- Desenha ponto")
	print_str("\n")
	
	print_str("3- Desenha retângulo sem preenchimento")
	print_str("\n")
	
	print_str("4- Converte para negativo da imagem")
	print_str("\n")
	
	print_str("5- Carrega imagem")
	print_str("\n")
	
	print_str("6- Encerra:")
	print_str("\n\n")
	
	print_str("Defina o número da opção desejada: ")
	
	get_int

# faz um switch-case com a opção inserida no menu principal
define_opcao:
	beq $v0, 1, get_point
	beq $v0, 2, draw_point
	beq $v0, 3, draw_empty_retangle
	beq $v0, 4, convert_negative
	beq $v0, 5, load_image
	beq $v0, 6, exit
	
op_inv:
	print_str("\n\nEscolha uma opcao valida!")
	j inicializa
	
# Pergunta o ponto e mostra ele no display
get_point:
	print_str("\n\nInsira a coordenada x do ponto desejado: ")
	get_int
	move $t0, $v0
	
	print_str("\nInsira a coordenada y do ponto desejado: ")
	get_int
	move $t1, $v0
	
	lw $t7, _bmpDim			# dimensao da matriz
	
	# Verifica limites da matriz
	bltz $t0, setpixel_exit		# Exit if x < 0
	nop
	bltz $t1, setpixel_exit		# Exit if y < 0
	nop
	bgt $t0, $t7, setpixel_exit	# Exit if x > dimension
	nop
	bgt $t1, $t7, setpixel_exit	# Exit if y > dimension
	
	lw $t8, address			# Get bitmap address
	addiu $t8, $t8, 0X00003f00	# add mask to offset new matrix's indexation
	
	srl $t8, $t8, 8			# set the address to receive the x position	
	
	subu $t8, $t8, $t0		# add to the designated x position
	
	sll $t8, $t8, 8			# get back the address + x position
	
	sll $t1, $t1, 2			# multiply by 4 to get the word address
	
	addu $t8, $t8, $t1		# add to the designated y position
	
	# Get the colour data of the address
	lw $t9, ($t8)
	
	## Pega componentes do ponto #
	
	# Pega componente R
	andi $t2, $t9, 0x000000FF
	
	# Pega componente G

	srl $t3, $t9, 8
	andi $t3, $t3, 0x000000FF
	
	# Pega componente B
	
	srl $t4, $t9, 16
	andi $t4, $t4, 0x000000FF
	
	print_str("\n")
	print_str("Os componentes RGB da coordenada são:")
	print_str("\n")
	
	print_str("R: ")
	print_int($t2)
	print_str("\t")

	print_str("G: ")
	print_int($t3)
	print_str("\t")

	print_str("B: ")
	print_int($t4)
	print_str("\n")
	
	j inicializa
	
draw_point:
	print_str("\n\nInsira a coordenada x do ponto desejado: ")
	get_int
	move $t0, $v0
	
	print_str("\nInsira a coordenada y do ponto desejado: ")
	get_int
	move $t1, $v0
	
	print_str("\nInsira o componente R da cor desejada do ponto: ")
	get_int
	move $t4, $v0
	
	print_str("\nInsira o componente G da cor desejada do ponto: ")
	get_int
	move $t5, $v0
	
	print_str("\nInsira o componente B da cor desejada do ponto: ")
	get_int
	move $t6, $v0
	
	lw $t7, _bmpDim			# dimensao da matriz
	
	# Verifica limites da matriz
	bltz $t0, setpixel_exit		# Exit if x < 0
	nop
	bltz $t1, setpixel_exit		# Exit if y < 0
	nop
	bgt $t0, $t7, setpixel_exit	# Exit if x > dimension
	nop
	bgt $t1, $t7, setpixel_exit	# Exit if y > dimension
	
	# Verifica limites do canal RGB
	bltz $t4, setrgb_exit		# Exit if R < 0
	nop
	bltz $t5, setrgb_exit		# Exit if G < 0
	nop
	bltz $t6, setrgb_exit		# Exit if B < 0
	nop
	
	bgtu $t4, 255, setrgb_exit	# Exit if R > 255
	nop
	bgtu $t5, 255, setrgb_exit	# Exit if G > 255
	nop
	bgtu $t6, 255, setrgb_exit	# Exit if B > 255
	nop
	
	lw $t8, address			# Get bitmap address
	addiu $t8, $t8, 0X00003f00	# add mask to offset new matrix's indexation
	
	srl $t8, $t8, 8			# set the address to receive the x position	
	
	subu $t8, $t8, $t0		# add to the designated x position
	
	sll $t8, $t8, 8			# get back the address + x position
	
	sll $t1, $t1, 2			# multiply by 4 to get the word address
	
	addu $t8, $t8, $t1		# add to the designated y position
		
	# Pega componente R 
	lw $t9, _mask
	or $t9, $t9, $t4
	
	# Pega componente G
	sll $t4, $t5, 8
	or $t9, $t9, $t4
	
	# Pega componente B
	sll $t4, $t6, 16
	or $t9, $t9, $t4
	
	# Put the colour data into the address
	sw $t9, ($t8)
		
	print_str("\n")
	print_str("Os componentes RGB foram colocadas no pixel!")
	print_str("\n")

	j inicializa

setpixel_exit:
	print_str("\n")
	print_str("Valor invalido! Escolha um numero positivo menor que 64!")
	print_str("\n")
	
	j inicializa		
	nop

setrgb_exit:
	print_str("\n")
	print_str("Valor invalido! Escolha um numero positivo ate 255!")
	print_str("\n")
	
	j inicializa			
	nop

draw_empty_retangle:
	print_str("\n\nInsira a coordenada x do primeiro ponto desejado: ")
	get_int
	move $t0, $v0
	
	print_str("\nInsira a coordenada y do primeiro ponto desejado: ")
	get_int
	move $t1, $v0
	
	print_str("\nInsira a coordenada x do segundo ponto desejado: ")
	get_int
	move $t2, $v0
	
	print_str("\nInsira a coordenada y do segundo ponto desejado: ")
	get_int
	move $t3, $v0
	
	j inicializa
	
convert_negative:
	j inicializa

  #-------------------------------------------------------------------------
  # Funcao load_image: carrega uma imagem em formato RAW RGB para memoria
  # Formato RAW: sequencia de pixels no formato RGB, 8 bits por componente
  # de cor, R o byte mais significativo
  #
  # Parametros:
  #  $a0: endereco do string ".asciiz" com o nome do arquivo com a imagem
  #  $a1: endereco de memoria para onde a imagem sera carregada
  #  $a2: endereco de uma palavra na memoria para utilizar como buffer
  #  $a3: tamanho da imagem em pixels
  #
  # A função foi implementada ...
  
load_image:
  # carrega imagem --------------------

  la $a0, image_name

  # salvar parametros da funcao nos termporarios
  move $t7, $a0	     # nome do arquivo
  move $t8, $a1      # endereco de carga
  move $t9, $a2	     # buffer para leitura de um pixel do arquivo
  
  li   $v0, 13       # system call para abertura de arquivo
  li   $a1, 0        # Abre arquivo para leitura (parâmtros são 0: leitura, 1: escrita)
  li   $a2, 0        # modo é ignorado
  syscall            # abre um arquivo (descritor do arquivo é retornado em $v0)
  move $t6, $v0      # salva o descritor do arquivo
  
  move $a0, $t6      # descritor do arquivo 
  move $a1, $t9      # endereço do buffer 
  li   $a2, 3        # largura do buffer
  
loop:  

  beq  $a3, $zero, close
  
  li   $v0, 14       # system call para leitura de arquivo
  syscall            # lê o arquivo
  lw   $t0, 0($a1)   # lê pixel do buffer	
  sw   $t0, 0($t8)   # escreve pixel no display
  addi $t8, $t8, 4   # próximo pixel
  addi $a3, $a3, -1  # decrementa countador
  
  j loop
  
  # fecha o arquivo 
close:  
  li   $v0, 16       # system call para fechamento do arquivo
  move $a0, $t6      # descritor do arquivo a ser fechado
  syscall            # fecha arquivo
  	
  j exit
  
  
exit:
  print_str("\nVolte Sempre!")
  li $v0 10	     # encerra programa
  syscall
# END OF PROGRAM 
  
