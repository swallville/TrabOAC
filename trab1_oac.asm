#-------------------------------------------------------------------------
#		Organização e Arquitetura de Computadores - Turma C 
#			Trabalho 1 - Assembly MIPS
#
# Semestre: 1/2017.
#
# Professor: Marcelo Grandi Mandelli.
#
# Nome:  Lukas Ferreira Machado			Matrícula: 12/0127377.
# Nome:  Eduardo Said Calil Vilaça		Matrícula: 13/0154253. 
# Nome:  Raphael Luis Souza de Queiroz 	        Matrícula: 13/0154989.
#
#  		"Lately, I've been working to convince myself that
#  		   everything is a computation." - Rudy Rucker.
#-------------------------------------------------------------------------

# descrição das variáveis utilizadas no programa
.data

image_name:   	    .asciiz "lenaeye.raw"   # nome da imagem a ser carregada
address: 	    .word   0x10040000	    # endereco do bitmap display na memoria
_mask: 	    	    .word   0x00000000	    # maskara para cor RGB	
_bmpDim:	    .word   63		    # Dimensao da matriz do bitmap (64 x 64), indexada de 0 a 63
buffer:		    .word   0		    # configuracao default do MARS
size:		    .word   4096            # numero de pixels da imagem
answer:		    .space  256

.text # início do programa main

j inicializa

  #-------------------------------------------------------------------------
  # Função print_int: 
  #  Printa um inteiro no console.
  #
  # Parametros:
  #  x: Um inteiro.
  #
  # Assertivas de entrada:
  #  type_of(x) == int.
  #
  # Asserivas de saida:
  #  retorna um inteiro válida imprensa em console.
  #
  # Retorno:
  #  A função printa no console um inteiro.
  #-----------------------------------------------------------------------

.macro print_int (%x)
	li $v0, 1
	add $a0, $zero, %x
	syscall
.end_macro

  #-------------------------------------------------------------------------
  # Função get_int: 
  #  Printa um inteiro no console.
  #
  # Parametros:
  #  void.
  #
  # Assertivas de entrada:
  #  void.
  #
  # Asserivas de saida:
  #  retorna um inteiro valido.
  #
  # Retorno:
  #  A função retorna um inteiro.
  #-----------------------------------------------------------------------

.macro get_int
	li $v0, 5             # Pega a opção inserida
	syscall
.end_macro

  #-------------------------------------------------------------------------
  # Função print_str: 
  #  Printa uma string no console.
  #
  # Parametros:
  #  str:  Uma string.
  #
  # Assertivas de entrada:
  #  type_of(str) == string.
  #
  # Asserivas de saida:
  #  retorna uma string válida imprensa em console.
  #
  # Retorno:
  #  A função printa no console uma string.
  #-----------------------------------------------------------------------

.macro print_str (%str)
	.data
		myLabel: .asciiz %str
	.text
		li $v0, 4
		la $a0, myLabel
		syscall
.end_macro

  #-------------------------------------------------------------------------
  # Função iniciliaza: 
  #  Seta os parâmetros utilizados pela função load_image.
  #
  # Parametros:
  #  void.
  #
  # Assertivas de entrada:
  #  void.
  #
  # Asserivas de saida:
  #  $a1 == address, $a2 == buffer, $a3 == size.
  #
  # Retorno:
  #  A função seta os parâmetros utilizados pela função load_image.
  #-----------------------------------------------------------------------
  	
inicializa:
	lw $a1, address
  	la $a2, buffer
  	lw $a3, size
  	li $s7, 0   # Flag booleana para saber se a imagem deve ser negativada ou não
  		    # 0 = carrega normal 1 = carrega o negativo dela

  #-------------------------------------------------------------------------
  # Função mostra_menu: 
  #  Seta um ponto nas coordenadas x e y as cores fornecidas em RGB.
  #
  # Parametros:
  #  option: Um inteiro entre 1 e 6 definindo a escolha do menu pelo usuario.
  #
  # Assertivas de entrada:
  #  1 <= option <= 6.
  #
  # Asserivas de saida:
  #  Se option < 1 OU option > 6
  #	return menu.	
  #
  # Retorno:
  #  A função desenha o menu do programa no console.
  #-----------------------------------------------------------------------
  
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

  #-------------------------------------------------------------------------
  # Função define_opcao: 
  #  Faz um switch-case com a opção inserida no menu principal.
  #
  # Parametros:
  #  Inteiro passado pelo usuario sendo a opção escolhida pelo mesmo.
  #
  # Assertivas de entrada:
  #  type_of(option) == int. 1 <= option <= 6.
  #
  # Asserivas de saida:
  #  Se option < 1 OU option > 6
  #	return op_inv().	 
  #
  # Retorno:
  #  A função chama o item do menu selecionado.
  #-----------------------------------------------------------------------

define_opcao:
	beq $v0, 1, get_point
	beq $v0, 2, draw_point
	beq $v0, 3, draw_empty_retangle
	beq $v0, 4, load_negative_image
	beq $v0, 5, load_image
	beq $v0, 6, exit
	
  #-------------------------------------------------------------------------
  # Função op_inv: 
  #  Printa na tela um string dizendo ao usuario que sua escolha foi invalida.
  #
  # Parametros:
  #  void.
  #
  # Assertivas de entrada:
  #  void.
  #
  # Asserivas de saida:
  #  print_str("\n\nEscolha uma opcao valida!") != empty.
  #
  # Retorno:
  #  Printa na tela um string dizendo ao usuario que sua escolha foi invalida.
  #----------------------------------------------------------------------- 
	
op_inv:
	print_str("\n\nEscolha uma opcao valida!")
	j inicializa
	
  #-------------------------------------------------------------------------
  # Função get_point: 
  #  Retorna as cores fornecidas em RGB no ponto de coordenadas x e y.
  #
  # Parametros:
  #  $x: posicao x do ponto desejado.
  #  $y: posicao y do ponto desejado.
  #
  # Assertivas de entrada:
  #  0 <= x && y <= 255.
  #
  # Asserivas de saida:
  #  return != -1 (erro).	
  #
  # Retorno:
  #  $val: valor da cor em RGB do ponto de coordenadas x e y, mostrando-o
  # no console separado pelo seus canais RGB.
  #-----------------------------------------------------------------------
	
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
	
	
	addi $sp, $sp, -8 		# stack receives 2 items
	sw $t1, 4($sp)			# y
	sw $t0, 0($sp)			# x
	
	jal get_pointfunc		# get_point's implementation
	
	lw $t2, 0($sp)  		# load B
	lw $t3, 4($sp)  		# load G
	lw $t4, 8($sp)  		# load R
	
	print_str("\n")
	print_str("Os componentes RGB da coordenada são:")
	print_str("\n")
	
	print_str("R: ")
	print_int($t4)
	print_str("\t")

	print_str("G: ")
	print_int($t3)
	print_str("\t")

	print_str("B: ")
	print_int($t2)
	print_str("\n")
	
	addi $sp, $sp, 12       	# remove 3 items of the stack
	
	print_str("\n")
	print_str("Deseja continuar? [y/n]")
	
	la  $a0, answer
    	li  $a1, 3
    	li  $v0, 8
    	syscall

    	lb  $t4, 0($a0)

    	beq $t4, 'y', inicializa
    	beq $t4, 'Y', inicializa
    	beq $t4, 'n', exit
    	beq $t4, 'N', exit
	
	
  #-------------------------------------------------------------------------
  # Função get_pointfunc: 
  #  Implementação da função get_point.
  #
  # Parametros:
  #  $x: posicao x do ponto desejado.
  #  $y: posicao y do ponto desejado.
  #
  # Assertivas de entrada:
  #  0 <= x && y <= 255.
  #
  # Asserivas de saida:
  #  return != -1 (erro).	
  #
  # Retorno:
  #  $val: valor da cor em RGB do ponto de coordenadas x e y, mostrando-o
  # no console separado pelo seus canais RGB.
  #-----------------------------------------------------------------------
	
get_pointfunc:
	lw $t8, address			# Get bitmap address
	addiu $t8, $t8, 0X00003f00	# add mask to offset new matrix's indexation
	
	lw $t0, 0($sp)  		# load x
	lw $t1, 4($sp)  		# load y
	
	addi $sp, $sp, 8       		# remove 2 items of the stack
	
	srl $t8, $t8, 8			# set the address to receive the x position	
	
	subu $t8, $t8, $t0		# add to the designated x position
	
	sll $t8, $t8, 8			# get back the address + x position
	
	sll $t1, $t1, 2			# multiply by 4 to get the word address
	
	addu $t8, $t8, $t1		# add to the designated y position
	
	# Get the colour data of the address
	lw $t9, ($t8)
	
	## Pega componentes do ponto #
	
	# Pega componente B
	andi $t2, $t9, 0x000000FF
	
	# Pega componente G

	srl $t3, $t9, 8
	andi $t3, $t3, 0x000000FF
	
	# Pega componente R
	
	srl $t4, $t9, 16
	andi $t4, $t4, 0x000000FF
	
	addi $sp, $sp, -12 		# stack receives 3 items
	sw $t4, 8($sp)			# R
	sw $t3, 4($sp)			# G
	sw $t2, 0($sp)			# B
	
	jr $ra			        # return to get_point
	
  #-------------------------------------------------------------------------
  # Função draw_point: 
  #  Seta um ponto nas coordenadas x e y as cores fornecidas em RGB.
  #
  # Parametros:
  #  $x: posicao x do ponto desejado.
  #  $y: posicao y do ponto desejado.
  #  $val: valor da cor em RGB separado-se cada canal ao pedir ao usuario.
  #
  # Assertivas de entrada:
  #  0 <= x && y <= 255.
  #  val tem que ser um hexadecimal válido.
  #
  # Asserivas de saida:
  #  return != -1 (erro).	
  #
  # Retorno:
  #  A função desenha um ponto de cor definida pelo valor val na posição 
  # denotada por x e y do Bitmap Display.
  #-----------------------------------------------------------------------
  
draw_point:
	print_str("\n\nInsira a coordenada x do ponto desejado: ")
	get_int
	move $t0, $v0
	
	print_str("\nInsira a coordenada y do ponto desejado: ")
	get_int
	move $t1, $v0
	
	print_str("\nInsira o nivel de Vermelho (R) desejado [0-255]: ")
	get_int
	move $t4, $v0
	
	print_str("\nInsira o nivel de Verde (G) desejado [0-255]: ")
	get_int
	move $t5, $v0
	
	print_str("\nInsira o nivel de Azul (B) desejado [0-255]: ")
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
	
	addi $sp, $sp, -20 		# stack receives 5 items
	sw $t0, 16($sp)			# x
	sw $t1, 12($sp)			# y
	sw $t4, 8($sp)			# R
	sw $t5, 4($sp)			# G
	sw $t6, 0($sp)			# B
	
	jal draw_pointfunc		# draw_point's implementation
	
	addi $sp, $sp, 20       	# remove 5 items of the stack
	
	print_str("\n")
	print_str("Os componentes RGB foram colocadas no pixel!")
	print_str("\n")

	j inicializa
	
  #-------------------------------------------------------------------------
  # Função draw_pointfunc: 
  # Implementação da função draw_point.
  #
  # Parametros:
  #  $x: posicao x do ponto desejado.
  #  $y: posicao y do ponto desejado.
  #  $val: valor da cor em RGB separado-se cada canal ao pedir ao usuario.
  #
  # Assertivas de entrada:
  #  0 <= x && y <= 255.
  #  val tem que ser um hexadecimal válido.
  #
  # Asserivas de saida:
  #  return != -1 (erro).	
  #
  # Retorno:
  #  A função desenha um ponto de cor definida pelo valor val na posição 
  # denotada por x e y do Bitmap Display.
  #-----------------------------------------------------------------------
  	
draw_pointfunc:
	lw $t8, address			# Get bitmap address
	addiu $t8, $t8, 0X00003f00	# add mask to offset new matrix's indexation
	
	lw $t6, 0($sp)  		# load B
	lw $t5, 4($sp)  		# load G
	lw $t4, 8($sp)  		# load R
	lw $t1, 12($sp)  		# load y
	lw $t0, 16($sp)  		# load x
	
	srl $t8, $t8, 8			# set the address to receive the x position	
	
	subu $t8, $t8, $t0		# add to the designated x position
	
	sll $t8, $t8, 8			# get back the address + x position
	
	sll $t1, $t1, 2			# multiply by 4 to get the word address
	
	addu $t8, $t8, $t1		# add to the designated y position
		
	# Pega componente B 
	lw $t9, _mask
	or $t9, $t9, $t6
	
	# Pega componente G
	sll $t6, $t5, 8
	or $t9, $t9, $t6
	
	# Pega componente R
	sll $t6, $t4, 16
	or $t9, $t9, $t6
	
	# Put the colour data into the address
	sw $t9, ($t8)
	
	jr $ra 			      	# return to draw_point
	
  #-------------------------------------------------------------------------
  # Função setpixel_exit: 
  #  Função que trata caso de erro de input do usuario ao dar as coordenadas
  # desejadas pelo mesmo.
  #
  # Parametros:
  #  void.
  #
  # Assertivas de entrada:
  #  void.
  #
  # Asserivas de saida:
  #  print_str("Valor invalido! Escolha um numero positivo menor que 64!") 
  #    != empty.	
  #
  # Retorno:
  #  A função retorna uma string dizendo que o usuario inseriu um valor
  # invalido para indexar a matriz e o retorna ao menu inicial.
  #-----------------------------------------------------------------------	

setpixel_exit:
	print_str("\n")
	print_str("Valor invalido! Escolha um numero positivo menor que 64!")
	print_str("\n")
	
	j inicializa		
	nop

  #-------------------------------------------------------------------------
  # Função setrgb_exit: 
  #  Função que trata caso de erro de input do usuario ao dar os parâmetros
  # RGB da cor desejada.
  #
  # Parametros:
  #  void.
  #
  # Assertivas de entrada:
  #  void.
  #
  # Asserivas de saida:
  #  print_str("Valor invalido! Escolha um numero positivo ate 255!")
  #    != empty.	
  #
  # Retorno:
  #  A função retorna uma string dizendo que o usuario inseriu um valor
  # invalido para os parâmetros RGB da cor desejada.
  #-----------------------------------------------------------------------	

setrgb_exit:
	print_str("\n")
	print_str("Valor invalido! Escolha um numero positivo ate 255!")
	print_str("\n")
	
	j inicializa			
	nop
	
  #-------------------------------------------------------------------------
  # Função draw_empty_retangle: 
  #  Desenha no Bitmap Display um retângulo de acordo com os limites e a
  # cor fornecidos pelo usuário.
  #
  # Parametros:
  #  $xi: coordenada x do primeiro coordenada do retângulo desejado.
  #  $yi: coordenada y do primeiro coordenada do retângulo desejado.
  #  $xf: coordenada x da segunda coordenada do retângulo desejado.
  #  $yf: coordenada y da segunda coordenada do retângulo desejado.
  #  $val: cor em RGB desejada no retângulo.
  #
  # Assertivas de entrada:
  #  0 <= xi && yi && xf && yf <= 255.
  #  val tem que ser um hexadecimal válido.
  #
  # Asserivas de saida:
  #  return != -1 (erro).	
  #
  # Retorno:
  #  A função desenha um retângulo de cor definida pelo valor val na posição 
  # delimita por xi, yi, xf e yf no Bitmap Display.
  #-------------------------------------------------------------------------

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
	
	print_str("\nInsira o nivel de Vermelho (R) desejado [0-255]: ")
	get_int
	move $t4, $v0
	
	print_str("\nInsira o nivel de Verde(G) desejado [0-255]: ")
	get_int
	move $t5, $v0
	
	print_str("\nInsira o nivel de Azul(B) desejado [0-255]: ")
	get_int
	move $t6, $v0
	
	lw $t7, _bmpDim			# dimensao da matriz
	
	# Verifica limites da matriz
	bltz $t0, setpixel_exit		# Exit if x1 < 0
	nop
	bltz $t1, setpixel_exit		# Exit if y1 < 0
	nop
	bltz $t2, setpixel_exit		# Exit if x2 < 0
	nop
	bltz $t3, setpixel_exit		# Exit if y2 < 0
	nop
	
	bgt $t0, $t7, setpixel_exit	# Exit if x1 > dimension
	nop
	bgt $t1, $t7, setpixel_exit	# Exit if y1 > dimension
	nop
	bgt $t2, $t7, setpixel_exit	# Exit if x2 > dimension
	nop
	bgt $t3, $t7, setpixel_exit	# Exit if y2 > dimension
	
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
	
	addu $s0, $t0, $zero		#auxiliar variable for saving initial X position (aux = xi)
	addu $s1, $t1, $zero		#auxiliar varaible for saving initial Y position (aux2 = yi)
	
	addi $sp, $sp, -20 		# stack receives 5 items
	sw $t0, 16($sp)			# x
	sw $t1, 12($sp)			# y
	sw $t4, 8($sp)			# R
	sw $t5, 4($sp)			# G
	sw $t6, 0($sp)			# B
	
	jal draw_pointfunc		# draw_point's implementation
	
	lw $t6, 0($sp)  		# load B
	lw $t5, 4($sp)  		# load G
	lw $t4, 8($sp)  		# load R
	lw $t1, 12($sp)  		# load y
	lw $t0, 16($sp)  		# load x
	
	addi $sp, $sp, 20       	# remove 5 items of the stack
draw1_y:	#loop for drawing lower side of the empty rectangle
	beq $t1, $t3, draw1_x		#condition for exit the loop (y = yf)
	
	slt $s4, $t3, $t1
	bne $s4, $zero, decrement1_y
	addi $t1, $t1, 1		#increment position Y for drawing next point (y = y + 1)
	j draw_1
decrement1_y:
	addi $t1, $t1, -1
draw_1:		
	addi $sp, $sp, -20 		# stack receives 5 items
	sw $t0, 16($sp)			# x
	sw $t1, 12($sp)			# y
	sw $t4, 8($sp)			# R
	sw $t5, 4($sp)			# G
	sw $t6, 0($sp)			# B
	
	jal draw_pointfunc		# draw_point's implementation
	
	lw $t6, 0($sp)  		# load B
	lw $t5, 4($sp)  		# load G
	lw $t4, 8($sp)  		# load R
	lw $t1, 12($sp)  		# load y
	lw $t0, 16($sp)  		# load x
	
	addi $sp, $sp, 20       	# remove 5 items of the stack
	
	j draw1_y
draw1_x:	#loop for drawing right side of the empty rectangle
	beq $t0, $t2, draw2_y		#condition for exit the loop (x = xf)
	
	slt $s4, $t2, $t0
	bne $s4, $zero, decrement1_x
	addi $t0, $t0, 1		#increment position X for drawing next point (x = x + 1)
	j draw_2
decrement1_x:
	addi $t0, $t0, -1
draw_2:
	addi $sp, $sp, -20 		# stack receives 5 items
	sw $t0, 16($sp)			# x
	sw $t1, 12($sp)			# y
	sw $t4, 8($sp)			# R
	sw $t5, 4($sp)			# G
	sw $t6, 0($sp)			# B
	
	jal draw_pointfunc		# draw_point's implementation
	
	lw $t6, 0($sp)  		# load B
	lw $t5, 4($sp)  		# load G
	lw $t4, 8($sp)  		# load R
	lw $t1, 12($sp)  		# load y
	lw $t0, 16($sp)  		# load x
	
	addi $sp, $sp, 20       	# remove 5 items of the stack
	
	j draw1_x
draw2_y:	#loop for drawing upper side of the empty rectangle
	beq $t1, $s1, draw2_x		#condition for exit the loop (y = yi)
	
	slt $s4, $t3, $s1
	bne $s4, $zero, increment2_y
	addi $t1, $t1, -1		#as y = yf, decrement position Y for drawing previous point (y = y - 1)
	j draw_3
increment2_y:
	addi $t1, $t1, 1
draw_3:
	addi $sp, $sp, -20 		# stack receives 5 items
	sw $t0, 16($sp)			# x
	sw $t1, 12($sp)			# y
	sw $t4, 8($sp)			# R
	sw $t5, 4($sp)			# G
	sw $t6, 0($sp)			# B
	
	jal draw_pointfunc		# draw_point's implementation
	
	lw $t6, 0($sp)  		# load B
	lw $t5, 4($sp)  		# load G
	lw $t4, 8($sp)  		# load R
	lw $t1, 12($sp)  		# load y
	lw $t0, 16($sp)  		# load x
	
	addi $sp, $sp, 20       	# remove 5 items of the stack
	
	j draw2_y
draw2_x:	#loop for drawing left side of the empty rectangle
	beq $t0, $s0, inicializa		#condition for exit the loop (x = xi)
	slt $s4, $t2, $s0
	bne $s4, $zero, increment2_x
	addi $t0, $t0, -1		#as x = xf, decrement position X for drawing previous point (x = x - 1)
	j draw_4
increment2_x:
	addi $t0, $t0, 1
draw_4:
	addi $sp, $sp, -20 		# stack receives 5 items
	sw $t0, 16($sp)			# x
	sw $t1, 12($sp)			# y
	sw $t4, 8($sp)			# R
	sw $t5, 4($sp)			# G
	sw $t6, 0($sp)			# B
	
	jal draw_pointfunc		# draw_point's implementation
	
	lw $t6, 0($sp)  		# load B
	lw $t5, 4($sp)  		# load G
	lw $t4, 8($sp)  		# load R
	lw $t1, 12($sp)  		# load y
	lw $t0, 16($sp)  		# load x
	
	addi $sp, $sp, 20       	# remove 5 items of the stack
	
	j draw2_x


  #-------------------------------------------------------------------------
  # Função convert_negative: 
  #  Retorna o negativo da imagem atual do Bitmap Display.
  #
  # Parametros:
  #  void.
  #
  # Assertivas de entrada:
  #  void.
  #
  # Asserivas de saida:
  #  return inverse(Bitmap_Display_Image).	
  #
  # Retorno:
  #  A função retorna o negativo da imagem no Bitmap Display.
  #------------------------------------------------------------------------- 
	
convert_negative:
	j inicializa

  #-------------------------------------------------------------------------
  # Função load_image: 
  #  Carrega uma imagem em formato RAW RGB para memoria.
  # Formato RAW: 
  #  Sequência de pixels no formato RGB, 8 bits por componente de cor, 
  # R o byte mais significativo.
  #
  # Parametros:
  #  $a0: endereco do string ".asciiz" com o nome do arquivo com a imagem.
  #  $a1: endereco de memoria para onde a imagem sera carregada.
  #  $a2: endereco de uma palavra na memoria para utilizar como buffer.
  #  $a3: tamanho da imagem em pixels.
  #
  # Assertivas de entrada:
  # type_of($a0) == string. $a1 precisa ser um endereco de memoria válido.
  # $a2 precisa ser um endereco de memoria válido. type_of($a3) == int.
  #
  # Asserivas de saida:
  #  return imagem no Bitmap Display.	
  #
  # Retorno:
  #  A função retorna a imagem carregada no Bitmap Display.
  #
  # A função foi implementada ...
  #-------------------------------------------------------------------------
  
load_negative_image:
	li $s7, 1 # s7 é uma flag booleana para avisar que a imagem
	          # deve ser carregada em seu modo negativo 	
  
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
  
  # Verifica se a imagem será representada na forma original ou negativada
  beq $s7, 1, loop_negative
  j loop
  
  #-------------------------------------------------------------------------
  # Função loop: 
  #  Função para gerar o loop para ler cada pixel da imagem aberta pela 
  # função load_image.
  #
  # Parametros:
  # $a3: número de pixels na imagem.
  #
  # Assertivas de entrada:
  #  $a3 == _bmpDim * _bmpDim.
  #
  # Asserivas de saida:
  #  $a3 == 0.
  #
  # Retorno:
  #  void.
  #-----------------------------------------------------------------------
  
loop:  

  beq  $a3, $zero, close
  li   $v0, 14       # system call para leitura de arquivo
  syscall            # lê o arquivo
  lw   $t0, 0($a1)   # lê pixel do buffer	
  sw   $t0, 0($t8)   # escreve pixel no display
  addi $t8, $t8, 4   # próximo pixel
  addi $a3, $a3, -1  # decrementa contador
  
  j loop
 
 
 modify_rgb:
 	## Pega componentes do ponto e negativa #
 	li $t4, 255
	
	# Pega componente B
	andi $t1, $t0, 0x000000FF
	sub  $t1, $t4, $t1
	
	# Pega componente G

	srl $t2, $t0, 8
	andi $t2, $t2, 0x000000FF
	sub  $t2, $t4, $t2
	sll  $t2, $t2, 8
	
	# Pega componente R
	
	srl $t3, $t0, 16
	andi $t3, $t3, 0x000000FF
	sub  $t3, $t4, $t3
	andi $t3, $t3, 0x0000FF00
	sll  $t3, $t3, 8
 	
 	add $t0, $t1, $t2
 	add $t0, $t0, $t3
 	
 	jr $ra
 
loop_negative:
 	beq  $a3, $zero, close
  	li   $v0, 14       # system call para leitura de arquivo
  	syscall            # lê o arquivo
  	lw   $t0, 0($a1)   # lê pixel do buffer
  
	jal  modify_rgb
  		
  	sw   $t0, 0($t8)   # escreve pixel no display
  	addi $t8, $t8, 4   # próximo pixel
  	addi $a3, $a3, -1  # decrementa contador
  
  	j loop_negative
  
  #-------------------------------------------------------------------------
  # Função close: 
  #  Fecha o arquivo apos a execução da função load_image.
  #
  # Parametros:
  # void.
  #
  # Assertivas de entrada:
  #  void.
  #
  # Asserivas de saida:
  #  arquivo aberto foi fechado com sucesso.
  #
  # Retorno:
  #  void.
  #-----------------------------------------------------------------------

close:  
  li   $v0, 16       # system call para fechamento do arquivo
  move $a0, $t6      # descritor do arquivo a ser fechado
  syscall            # fecha arquivo
  	
  j inicializa
  
  #-------------------------------------------------------------------------
  # Função exit: 
  #  Termina a execução do main do programa.
  #
  # Parametros:
  # void.
  #
  # Assertivas de entrada:
  #  void.
  #
  # Asserivas de saida:
  #  programa executado com sucesso.
  #
  # Retorno:
  #  void.
  #-----------------------------------------------------------------------
 
exit:
  print_str("\nVolte Sempre!")
  li $v0 10	     # encerra programa
  syscall
# END OF PROGRAM 
