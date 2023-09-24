# Felipe Chatalov   118992
# Matheus Molina    120118
# ---------------   ######

# 1. crud basico para imoveis, insercao, remocao, consulta,
# gravar cadastro, recuparar cadastro e relatorio de registros
# 2. lista encadeada dinamica usando malloc para armazenar registros
# 3. registro: nome, cpf, celular, tipo do imovel(casa ou ap), endereco
# (cidade bairro rua e numero), num de quartos e suites, se tem banheiro
# social cozinha sala e garagem, metragem total e valor do aluguel 
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
	cpf: 		 .space  12  # 11 char's 
	celular:     .space  44  # 11 char's
	tipoImovel:  .byte 00000000  # 1 byte 0=casa, 1=ap
	enderecoCdd: .space  40  # 10 char's
	enderecoBrr: .space  40  # 10 char's
	enderecoRua: .space  40  # 10 char's
	enderecoNum: .int 0 # 4 bytes each int
	numQuartos:  .int 0
	numSuites:   .int 0
	contembcsg:  .byte 00000000 # 4 ultimos bits usado para banheiro, cozinha, sala e garagem
	metragem:    .int 0
	valorAluguel:.int 0
	# total bytes: 80 + 12 + 44 +40*3 + 1*2 + 4*5 = 278
	# 278 bytes per record
	p_struct: .int 0
	tam_struct: .int 278

	# check later
	structsArray: .int 0
	currentStruct: .int 0
	separatorPtr: .int 0

	# check later
	temp: .int 0

	opcao: .int 0
	tipoInt: .asciz "%d"

	# check later
	ten: .int 10

	# check later
	testPrintFile: .asciz "Teste %d\n"

	bufferSize: .int 0

	fileName: .asciz "registros.txt"
    testFileName: .asciz "test.txt"
	testPrintString: .asciz "Teste %s\n"
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

	push    %ebx        # preserve working registers
	push    %edx
	push    %esi

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
	jmp _nxchr          # go back for another numeral
_inval:
   pop  %esi            # recover saved registers
   pop  %edx
   pop  %ebx
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

_AlocaMemoria:
	# memory allocation
	movl $tam_struct, %eax
	call malloc
	movl %eax, p_struct

	# save pointer to array of structs
	movl structsArray, %ebx
	addl currentStruct, %ebx
	movl p_struct, %ebx
	addl $4, currentStruct
	
	RET

_getDataRef:
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edx

	movl $buffer, %ebx
	movl $'|', %eax
	movl $0, %ecx
	movl separatorPtr, %edx
_gdrLoop:
	cmpl $150, %ecx
	je _gdrEnd

	movl %ecx, temp
	cmpl %eax, (%ebx)
	jne _next

	movl %ecx, (%edx)
	addl $4, %edx
	incl %ecx
	addl $1, %ebx
	jmp _gdrLoop

_next:
	incl %ecx
	addl $1, %ebx
	jmp _gdrLoop

_gdrEnd:
	movl %edx, separatorPtr
	popl %edx
	popl %ecx
	popl %ebx
	popl %eax
	RET



CopyStringToStruct:
	pushl %eax
	pushl %ebx

	movl $buffer, %ebx
	movl $'|', %eax
_cstsCompare:
	cmpl (%ebx), %eax
	je _cstsEnd

	movl (%ebx), %edx
	addl $1, %ebx
	addl $1, %edx
	jmp _cstsCompare
_cstsEnd:
	popl %ebx
	popl %eax
	RET

_copyStr:
	pushl %eax
	pushl %ebx

	# pushl %edx  # considering edx is ptr to struct


	movl p_struct, %edi
	movl $124, %eax
	movl $buffer, %esi
_csLoop:
	# pq nao funciona essa comparacaos?
	cmpl (%esi), %eax
	je _csEnd

	# copy char from buffer to struct
	# nao copia??
	movl (%esi), %edi
	# next char and loop
	addl $1, %esi
	addl $1, %edi
	jmp _csLoop
_csEnd:
	popl %esi
	popl %eax

	RET


_PassaDadosParaStruct:
	movl p_struct, %edx
	
	# prob remove later not used
	# get data separator '|' reference for each data in buffer 
	#call _getDataRef

	# copy string from buffer and pass to struct at %edx
	#call CopyStringToStruct
	call _copyStr

	# remove later
	#movl p_struct, %eax
	#pushl %eax
	#pushl $testPrintString
	#call printf
	#addl $8, %esp
	
	RET



CarregaRegistroNaMemoria:
	call _AlocaMemoria
	call _PassaDadosParaStruct

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

	call _getBufferSize
	movl %eax, bufferSize

	# print for debug
	pushl %eax
	pushl $testPrintFile
	call printf
	addl $8, %esp

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
































