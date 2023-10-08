# Felipe Chatalov   118992
# Matheus Molina    120118
# ---------------   ######

# 1. crud basico para imoveis, insercao, remocao, consulta,
# gravar cadastro, recuparar cadastro e relatorio de registros
# 2. lista encadeada dinamica usando malloc para armazenar registros
# 3. registro: nome, celular, casa ou ap, endereco(cidade e bairro), num quartos
# (simples + suites), garagem(sim ou nao), metragem total, valor do aluguel 
# 4. consultas feitas por numero de comodos.
# 5. relatorio deve mostrar todos registros de forma ordenada
# 6. a remocao deve liberar o espaco de memoria alocada (pode se usar free)
# empilhando o endereco e chamala com call
# 7. lista encadeada manipulada em memoria e em disco, devendo todos os registros
# serem digitados a cada execucao, ou todos eles lidos/gravados durante execucao
# a manipulacao de disco para ler/escrever devera utilizar chamdas de sistemas,
# sem usar bibliotecas
# 8. com menu de opcoes
# 9. codigo comentado
# 10. caso tenha imoveis precadastrados, incluir no envio
# 10. relatorio contendo: participantes, descricao dos principais modulos desenvolvidos e autoavaliação do
# funcionamento (citar as partes que funcionam corretamente, as partes que nao
# funcionam corretamente e sob quais circunstancias, bem como as partes que nao foram
# implementadas).


# how to handle records?
# |namenamename|cpfcpfcpf|...
# use pipes to separate fields?
# |namename\0\0|...
# use \0 for null characters?

















.section .data
	abertura:	.asciz	"--Controle de cadastro de imoveis--\n"

	opcoes:		.asciz	"1 - Inserir\n2 - Remover\n3 - Consultar\n4 - Relatorio de registros\n0 - Sair\n"

	inserirTexto: 	.asciz	"Inserir\n"
	removerTexto: 	.asciz	"Remover\n"
	consultarTexto: .asciz	"Consultar\n"
	relatorioTexto: .asciz	"Relatorio de registros\n"

	# struct para registro
	nome:        .space  80  # 20 char's
	celular:     .space  44  # 11 char's
	tipoImovel:  .int 0 	 # 1 byte 0=casa, 1=ap
	enderecoCdd: .space  40  # 10 char's
	enderecoBrr: .space  40  # 10 char's
	numQuartos:  .int 0
	numSuites:   .int 0
	cntGaragem:  .int 0      # 4 ultimos bits usado para banheiro, cozinha, sala e garagem
	metragem:    .int 0
	valorAluguel:.int 0
	proximoRegistro: .int 0

	# total bytes: 80 + 44 + 4 + 40 + 40 + 4 + 4 + 4 + 4 + 4 + 4
	# 232 bytes per record
	p_struct: .int 0
	tam_struct: .int 232

	# check later
	firstStruct: .int 0
	currentStruct: .int 0
	separatorPtr: .int 0
	structByteOffset: .int 0
	bufferByteOffset: .int 0

	# check later
	temp: .int 0

	opcao: .int 0

	# check later
	ten: .int 10

	# check later
	testPrintFile: .asciz "Teste %d\n"

	bufferSize: .int 0

	# check later
	qtdRecords: .int 0

	tipoInt: .asciz "%d"
	tipoString: .asciz "%s"

	debugInserir: .asciz "Nome: %s\nCPF: %s\nCelular: %s\nTipo do imovel: %d\nEndereco: %s, %s, %s, %d\nNumero de quartos: %d\nNumero de suites: %d\nContem banheiro, cozinha, sala e garagem: %d\nMetragem: %d\nValor do aluguel: %d\n"

	fileName: .asciz "registros.txt"
    testFileName: .asciz "test.txt"
	testPrintString: .asciz "Teste %s\n"
	testPrintInt: .asciz "Teste %d\n"
    erroGenericoArquivo: .asciz "Erro no arquivo, codigo %d\n"

.section .bss
    
	
	
	.lcomm fileHandle, 4
    .lcomm testFileHandle, 4

    .lcomm buffer, 150 # 150 bytes to read

.section .text

.globl _start
_start:
	pushl	$abertura
	call	printf
	add $4, %esp

	call 	Menu
_fim:
	pushl 	$0
	call	exit


























_badfile:
    pushl %eax
    pushl $erroGenericoArquivo
    call printf
    addl $8, %esp

    movl %eax, %ebx   
    movl $1, %eax   
    int $0x80  

atoi:
	push    %edx        # preserve working registers
	push    %esi
	push    %edi

	mov $0, %edi
	
	mov $0, %eax        # initialize the accumulator
_nxchr:
	mov $0, %ebx        # clear all the bits in EBX
	mov (%esi), %bl     # load next character in BL
	inc %esi            # and advance source index

	cmp $'0', %bl       # does character preceed '0'?
	jl  _inval          # yes, it's not a numeral jl:jump lower
	cmp $'9', %bl       # does character follow '9'?
	jg  _inval          # yes, it's not a numeral jg:jump greater

	sub $'0', %bl       # else convert numeral to int
	mull ten            # multiply accumulator by ten. %eax * 10
	add %ebx, %eax      # and then add the new integer
	incl %edi
	jmp _nxchr          # go back for another numeral
_inval:
   movl %edi, %ebx
   pop  %edi
   pop  %esi            # recover saved registers
   pop  %edx

   RET

# return buffer size at %eax
_getBufferSize:
	pushl %ebx
	pushl %ecx
	pushl %edx


	movl $0, %eax
	movl $buffer, %ebx
	movl $150, %ecx
	movl $0, %edx
	
_gbsLoop:
	cmpl (%ebx), %eax
	je _gbsEnd

	incl %edx
	addl $1, %ebx
	jmp _gbsLoop

_gbsEnd:
	movl %edx, %eax
	popl %edx
	popl %ecx
	popl %ebx

	RET

_abreArquivoRDWR:
    # open file as rdwr
    movl $5, %eax          # sys call for open
    movl $fileName, %ebx   # file name
    movl $02, %ecx         # flags, read write
    movl $0744, %edx       # permissions
    int $0x80              # call kernel

    test %eax,%eax         # check for an error, if %eax is neg
    js _badfile            # if error

    movl %eax, fileHandle

    RET

_fechaArquivos:
	movl $6, %eax          # sys call for close
	movl fileHandle, %ebx  # file handle
	int $0x80              # call kernel

	# if still using test write, --> remove later <--
	movl $6, %eax          # sys call for close
	movl testFileHandle, %ebx  # file handle
	int $0x80              # call kernel

	RET

_writeBufferToTestFile:
    movl $5, %eax              # sys call for open
    movl $testFileName, %ebx   # file name
    movl $02, %ecx             # flags, read write
    movl $0744, %edx           # permissions
    int $0x80 

    test %eax,%eax         
    js _badfile            

    movl %eax, testFileHandle

    movl $4, %eax              # system call for write
    movl testFileHandle, %ebx  # file handle
    movl $buffer, %ecx         # buffer
    movl bufferSize, %edx      # buffer length
    int $0x80                  # call kernel

    test %eax,%eax             # check for an error, if %eax is neg
    js _badfile                # if error
    RET

_lerProximoRegistro:
    # read the next record
    movl $3, %eax          # sys call for read
    movl fileHandle, %ebx  # file handle
    movl $buffer, %ecx     # buffer
    movl $150, %edx        # bytes to read
    int $0x80              # call kernel

    test %eax,%eax        # check for an error, if %eax is neg
    js _badfile           # if error

    RET

_AlocaMemoriaParaRegistro:
	# memory allocation
	pushl tam_struct
	call malloc
	movl %eax, p_struct
	add $4, %esp
	
	RET


# copies string until a '|' is found
# from esi to edi
# can be offseted by ebx and ecx, in esi and edi
# also holds the final offset in ebx and ecx
CopyStringToStruct:
	pushl %eax
	pushl %edi
	pushl %esi
	
	leal buffer, %esi
	movl p_struct, %edi
	addl %ebx, %esi
	addl %ecx, %edi
_cstsCompare:
	lodsb
	incl %ebx
	cmpb $124, %al
	je _cstsEnd
	stosb
	jmp _cstsCompare
_cstsEnd:
	popl %esi
	popl %edi
	popl %eax
	RET



_PassaDadosParaStruct:
	# struct is as follows:
	# nome: 20chars
	# celular: 11chars
	# tipoImovel: int
	# enderecoCdd: 10chars
	# enderecoBrr: 10chars
	# numQuartos: int
	# numSuites: int
	# cntGaragem: int
	# metragem: int
	# valorAluguel: int
	# ptr

	# using 71 bytes in total in memory
	# ignoring ptr to the next, so we have 75 bytes in total with ptr

	# p_struct always hold the last struct allocated
	# currently passing buffer and p_struct inside the function
	# leal buffer, %esi
	# leal p_struct, %edi


	# read from buffer until "|" is found
	# in this case we reed 'name'
	# 20 characters total, 20bytes offset in struct
	movl $0, %ebx      # offset in buffer
	movl $0, %ecx      # offset in struct
	call CopyStringToStruct      
	movl %ebx, bufferByteOffset
	movl %ecx, structByteOffset
	
	# debug, read from buffer
	pushl p_struct
	pushl $testPrintString
	call printf
	addl $8, %esp

	# read the phone from buffer
	movl bufferByteOffset, %ebx
	movl $20, %ecx			   # 20 = nome
	call CopyStringToStruct    # ... + celular
	movl %ebx, bufferByteOffset
	movl %ecx, structByteOffset

	pushl p_struct
	pushl $testPrintString
	call printf
	addl $8, %esp

	# nao temos mais RG
	#movl bufferByteOffset, %ebx
	#movl $31, %ecx              # 31 = nome + celular
	#call CopyStringToStruct     # ... + rg
	#movl %ebx, bufferByteOffset
	#movl %ecx, structByteOffset

	# apenas para printar na tela
	pushl p_struct
	pushl $testPrintString
	call printf
	addl $8, %esp

	# copia um numero ate o proximo '|'
	# transforma chars em inteiro e guarda na struct
	pushl %esi
	leal buffer, %esi           # 31 = nome + celular
	addl bufferByteOffset, %esi	# ... + tipo = ap/casa
	call atoi
	popl %esi
	incl %ebx
	addl %ebx, bufferByteOffset
	movl p_struct, %edx
	movl %eax, 31(%edx)     #int to pos 31 in struct

	# apenas para printar na tela
	pushl %eax
	pushl $testPrintInt
	call printf
	addl $8, %esp


	movl bufferByteOffset, %ebx
	movl $35, %ecx              # 35 = nome + celular + tipo 
	call CopyStringToStruct     # ... + cidade
	movl %ebx, bufferByteOffset
	movl %ecx, structByteOffset



	movl bufferByteOffset, %ebx
	movl $45, %ecx              # 45 = nome + celular + tipo + cidade
	call CopyStringToStruct     # ... + bairro
	movl %ebx, bufferByteOffset
	movl %ecx, structByteOffset


	pushl %esi
	leal buffer, %esi           # 55 = nome + celular + tipo + cidade + bairro
	addl bufferByteOffset, %esi	# ... + quartos
	call atoi
	popl %esi
	incl %ebx
	addl %ebx, bufferByteOffset
	movl p_struct, %edx
	movl %eax, 55(%edx)     #int to pos 31 in struct

	pushl %esi
	leal buffer, %esi           # 59 = nome + celular + tipo + cidade + bairro + quartos
	addl bufferByteOffset, %esi	# ... + suites
	call atoi
	popl %esi
	incl %ebx
	addl %ebx, bufferByteOffset
	movl p_struct, %edx
	movl %eax, 59(%edx)     #int to pos 59 in struct

	pushl %esi
	leal buffer, %esi           # 63 = nome + celular + tipo + cidade + bairro + quartos + suites
	addl bufferByteOffset, %esi	# ... + cntGaragem
	call atoi
	popl %esi
	incl %ebx
	addl %ebx, bufferByteOffset
	movl p_struct, %edx
	movl %eax, 63(%edx)     #int to pos 63 in struct


	pushl %esi
	leal buffer, %esi           # 67 = nome + celular + tipo + cidade + bairro + quartos + suites
	addl bufferByteOffset, %esi	# ... + metragem
	call atoi
	popl %esi
	incl %ebx
	addl %ebx, bufferByteOffset
	movl p_struct, %edx
	movl %eax, 67(%edx)     #int to pos 67 in struct


	pushl %esi
	leal buffer, %esi           # 71 = nome + celular + tipo + cidade + bairro + quartos + suites
	addl bufferByteOffset, %esi	# ... + valoraluguel
	call atoi
	popl %esi
	incl %ebx
	addl %ebx, bufferByteOffset
	movl p_struct, %edx
	movl %eax, 71(%edx)     #int to pos 71 in struct


	# last we need a pointer to the next record



	RET

_InsereRegistro:
	# eax holds the pointer to the last record
	# p_struct holds the pointer to the new record
	movl $p_struct, %eax   # 71 is the offset to the pointer
	RET


_loopFinalLista:
	addl $71, %eax
	cmpl $0, (%eax)
	je _backFinalLista
	movl (%eax), %eax
	jmp _loopFinalLista

_InsereRegistroFinal:
	# if firstStruct == 0, then this is the first record
	# else: insert at the end of the list

	movl firstStruct, %eax
	cmpl $0, %eax
	jne _loopFinalLista   # eax holds ptr to last struct
_backFinalLista:
	call _InsereRegistro
	RET

CarregaRegistroNaMemoria:
	call _AlocaMemoriaParaRegistro
	call _PassaDadosParaStruct
	call _InsereRegistroFinal
	
	# caso seja o primeiro registro, nao temos um ponteiro
	# caso tenha, entao o ultimo registro aponta para este novo

	RET 


CarregarRegistrosDoDisco:
	# como saber qnts registros tem?
	# num de registros na 1 linha? 'N\n'?
	# ou ler um registro, andar o ponteiro pra frente, ve se tem algo
	# se tiver le prox, se n tiver para?
	
	# open "registros.txt" for rd wr and return the file handle at 'fileHandle'
    call _abreArquivoRDWR


	

    # read the next record and hold it in 'buffer'
    call _lerProximoRegistro


	# get buffer size and store at eax
	call _getBufferSize
	movl %eax, bufferSize
	# print for debug
	pushl %eax
	pushl $testPrintFile
	call printf
	addl $8, %esp



	#load buffer info to memory
	call CarregaRegistroNaMemoria

	# escreve em test.txt para fim de teste
    call _writeBufferToTestFile


	# close the file
	call _fechaArquivos

    RET




















PegarInput:
	pushl	$nome
	pushl	$tipoString
	call	scanf
	add $8, %esp

	pushl	$celular
	pushl	$tipoString
	call	scanf
	add $8, %esp

	pushl	$tipoImovel
	pushl	$tipoInt
	call	scanf
	add $8, %esp

	pushl	$enderecoCdd
	pushl	$tipoString
	call	scanf
	add $8, %esp

	pushl	$enderecoBrr
	pushl	$tipoString
	call	scanf
	add $8, %esp

	pushl	$numQuartos
	pushl	$tipoInt
	call	scanf
	add $8, %esp

	pushl	$numSuites
	pushl	$tipoInt
	call	scanf
	add $8, %esp

	pushl	$cntGaragem
	pushl	$tipoInt
	call	scanf
	add $8, %esp

	pushl	$metragem
	pushl	$tipoInt
	call	scanf
	add $8, %esp

	pushl	$valorAluguel
	pushl	$tipoInt
	call	scanf
	add $8, %esp

	# debug
	
	pushl $valorAluguel
	pushl $metragem
	pushl $cntGaragem
	pushl $numSuites
	pushl $numQuartos
	pushl $enderecoBrr
	pushl $enderecoCdd
	pushl $tipoImovel
	pushl $celular
	pushl $nome
	pushl $debugInserir
	call printf
	add $56, %esp


	RET



















































Menu:
	pushl	$opcoes
	call	printf
	add $4, %esp

	pushl	$opcao
	pushl	$tipoInt
	call	scanf
	add $8, %esp

	cmpl	$0, opcao
	jl	Menu
	cmpl    $4, opcao
	jg	Menu
	
	cmpl	$1, opcao
	je	Inserir
	cmpl	$2, opcao
	je	Remover
	cmpl	$3, opcao
	je	Consultar
	cmpl	$4, opcao
	je	Relatorio
	cmpl	$0, opcao
	je	_fim
	RET

Inserir:
	pushl	$inserirTexto
	call	printf
	add $4, %esp

	call PegarInput

	RET

Remover:
	pushl 	$removerTexto
	call	printf
	add $4, %esp
	RET

Consultar:
	pushl	$consultarTexto
	call	printf
	add $4, %esp
	RET

Relatorio:
	pushl	$relatorioTexto
	call	printf
	add $4, %esp
	
	call CarregarRegistrosDoDisco

	RET
































