# Felipe Chatalov   118992
# Matheus Molina    120118
# ---------------   ######

.section .data
	abertura:	.asciz	"--Controle de cadastro de imoveis--\n"

	opcoes:		.asciz	"1 - Inserir\n2 - Remover\n3 - Consultar\n4 - Relatorio de registros\n0 - Sair\n"

	inserirTexto: 	.asciz	"Inserir\n"
	removerTexto: 	.asciz	"Remover\n"
	consultarTexto: .asciz	"Consultar\n"
	relatorioTexto: .asciz	"Relatorio de registros\n"

	# struct para registro
	nome:        .space  20  # 20 char's
	celular:     .space  11  # 11 char's
	tipoImovel:  .int 0 	 # 4 bytes 0=casa, 1=ap
	enderecoCdd: .space  10  # 10 char's
	enderecoBrr: .space  10  # 10 char's
	numQuartos:  .int 0      # 4 bytes
	numSuites:   .int 0      # 4 bytes
	cntGaragem:  .int 0      # 4 ultimos bits usado para banheiro, cozinha, sala e garagem
	metragem:    .int 0      # 4 bytes
	valorAluguel:.int 0 	 # 4 bytes
	proximoRegistro: .int 0  # 4 bytes

	# total bytes: 20 + 11 + 4 + 10 + 10 + 4x6
	# 79 bytes
	# 1 char = 1 byte
	# 1 int  = 4 byte
	p_struct: .int 0
	tam_struct: .int 79

	firstStruct: .int 0
	structByteOffset: .int 0
	bufferByteOffset: .int 0

	numeroTotalRegistros: .int 0


	opcao: .int 0

	ten: .int 10

	byteSpace: .int 32

	bufferSize: .int 0
	bufferMaxSize: .int 87

	RemoveCelularStringHolder: .space 11
	test: .int 0
	stringHolder: .space 20
	

	buscaQuantidadeQuartos: .int 0
	RemoveQuantidadeQuartos: .int 0


	tipoInt: .asciz "%d"
	tipoString: .asciz "%s"

	debugInserir: .asciz "Nome: %s\nCelular: %s\nTipo do imovel: %d\nEndereco: %s, %s\nNumero de quartos: %d\nNumero de suites: %d\nContem garagem: %d\nMetragem: %d\nValor do aluguel: %d\n"
	InputPrintEntrada: .asciz "Adicionar um novo registro, digite as informaçoes abaixo\n"
	InputPrintNome: .asciz "Nome: "
	InputPrintCelular: .asciz "Celular: "
	InputPrintImovel: .asciz "Tipo do imovel (0 = casa, 1 = apartamento): "
	InputPrintCidade: .asciz "Cidade: "
	InputPrintBairro: .asciz "Bairro: "
	InputPrintQuartos: .asciz "Numero de quartos: "
	InputPrintSuites: .asciz "Numero de suites: "
	InputPrintGaragem: .asciz "Contem garagem (0 = nao, 1 = sim): "
	InputPrintMetragem: .asciz "Metragem: "
	InputPrintAlugel: .asciz "Valor do aluguel: "

	MostraNome: .asciz "Nome: %s\n"
	MostraCelular: .asciz "Celular: %s\n"
	MostraImovel: .asciz "Tipo do imovel: %d\n"
	MostraCidade: .asciz "Cidade: %s\n"
	MostraBairro: .asciz "Bairro: %s\n"
	MostraQuartos: .asciz "Numero de quartos: %d\n"
	MostraSuites: .asciz "Numero de suites: %d\n"
	MostraGaragem: .asciz "Contem garagem: %d\n"
	MostraMetragem: .asciz "Metragem: %d\n"
	MostraAlugel: .asciz "Valor do aluguel: %d\n"

	PrintNewLine: .asciz "\n"

	PrintBusca: .asciz "Busca por numero de quartos\n Digite o numero de quartos simples + suites"
	PrintRecordNotFound: .asciz "Registro nao encontrado\n"


	PrintRemove: .asciz "Remover registro\nDigite o numero de celular do registro a ser removido: "


	printMemoriaAlocada: .asciz "[debug]Memoria alocada no endereco %x\n"

	fileName: .asciz "registros.txt"
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

	# carrega os registros do txt para memoria
	call CarregarRegistrosDoDisco

	pushl	$abertura
	call	printf
	add $4, %esp

	call 	Menu
_fim:

	# reescreve todos os registros no arquivo
	call ReescreverRegistrosNoArquivo


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
# prob need to be rewriten
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

memset:
	pushl %eax
	pushl %ecx
	pushl %esi
	#leal buffer, %edi
	movl bufferMaxSize, %ecx
	movb byteSpace, %al
_memsetCopy:
	stosb   # copia al para edi
	loop _memsetCopy
_memsetEnd:
	popl %esi
	popl %ecx
	popl %eax
	RET


# memory to be erased in %edi
# size in %ecx
eraseStringGeneric:
	pushl %eax
	movb $0, %al
	rep stosb
	popl %eax
	RET

memsetStringHolder:
	pushl %eax
	pushl %edi
	pushl %ecx

	movb $0, %al
	movl $stringHolder, %edi
	movl $20, %ecx
	rep stosb
	
	popl %ecx
	popl %edi
	popl %eax
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

	RET

# can be offseted by ebx
_lerProximoRegistro:
    # read the next record
	movl bufferMaxSize, %ecx
	leal buffer, %edi
	call memset


    movl $3, %eax          # sys call for read
    movl fileHandle, %ebx  # file handle
    movl $buffer, %ecx     # buffer
    movl bufferMaxSize, %edx        # bytes to read
    int $0x80              # call kernel

    test %eax,%eax        # check for an error, if %eax is neg
    js _badfile           # if error

    RET

# aloca memoria igual a tam_struct
# e guarda em p_struct
_AlocaMemoriaParaRegistro:
	# memory allocation
	pushl tam_struct
	call malloc
	movl %eax, p_struct
	add $4, %esp

	pushl %eax
	pushl $printMemoriaAlocada
	call printf
	addl $8, %esp
	
	RET


# copies string until a '|' is found
# from esi to edi
# can be offseted by ebx and ecx, in esi and edi
# also holds the final offset in ebx and ecx
CopyStringBufferToStruct:
	pushl %eax
	pushl %edi
	pushl %esi
	
	leal buffer, %esi
	movl p_struct, %edi
	addl %ebx, %esi
	addl %ecx, %edi
_csbsCompare:
	lodsb
	incl %ebx
	cmpb $124, %al
	je _csbsEnd
	stosb
	jmp _csbsCompare
_csbsEnd:
	popl %esi
	popl %edi
	popl %eax
	RET

# need to have src and dst in %esi and %edi beforehand
# copies until null byte is found
CopyStringStringInputToStruct:
	pushl %eax
_csisCompare:
	lodsb
	cmpb $0, %al
	je _csisEnd
	stosb
	jmp _csisCompare
_csisEnd:
	popl %eax
	RET


# copy string from esi to edi until ecx != 0
CopyStringSelect:
	pushl %eax
_cssLoop:
	lodsb
	cmpb $0, %al
	je _cssEnd
	stosb
	loop _cssLoop
_cssEnd:

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


	# read from buffer until "|" is found
	# in this case we reed 'name'
	# 20 characters total, 20bytes offset in struct
	movl $0, %ebx      # offset in buffer
	movl $0, %ecx      # offset in struct
	call CopyStringBufferToStruct      
	movl %ebx, bufferByteOffset
	movl %ecx, structByteOffset


	# read the phone from buffer
	movl bufferByteOffset, %ebx
	movl $20, %ecx			   # 20 = nome
	call CopyStringBufferToStruct    # ... + celular
	movl %ebx, bufferByteOffset
	movl %ecx, structByteOffset


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


	movl bufferByteOffset, %ebx
	movl $35, %ecx              # 35 = nome + celular + tipo 
	call CopyStringBufferToStruct     # ... + cidade
	movl %ebx, bufferByteOffset
	movl %ecx, structByteOffset



	movl bufferByteOffset, %ebx
	movl $45, %ecx              # 45 = nome + celular + tipo + cidade
	call CopyStringBufferToStruct     # ... + bairro
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

	RET


# necessita do ponteiro para o registro em eax
MostraRegistro:
	pushl %eax

	leal (%eax), %esi       # nome
	leal stringHolder, %edi 
	movl $20, %ecx
	rep movsb

	pushl %eax              # for backup
	
	pushl $stringHolder
	pushl $MostraNome
	call printf
	addl $8, %esp
	
	popl %eax               # for backup
	addl $20, %eax
	pushl %eax
	
	
	call memsetStringHolder
	leal (%eax), %esi       # celular
	leal stringHolder, %edi
	movl $11, %ecx    
	rep movsb
	
	
	pushl $stringHolder
	pushl $MostraCelular
	call printf
	addl $8, %esp

	popl %eax               # for backup
	addl $11, %eax
	pushl %eax              # for backup

	movl (%eax), %ebx       # tipoImovel
	pushl %ebx
	pushl $MostraImovel
	call printf
	add $8, %esp

	popl %eax               # for backup
	addl $4, %eax
	pushl %eax              # for backup

	call memsetStringHolder
	leal (%eax), %esi       # enderecoCdd
	leal stringHolder, %edi
	movl $10, %ecx
	rep movsb
	pushl $stringHolder
	pushl $MostraCidade
	call printf
	addl $8, %esp

	popl %eax   		    # for backup
	addl $10, %eax
	pushl %eax              # for backup

	call memsetStringHolder
	leal (%eax), %esi       # enderecoBrr
	leal stringHolder, %edi
	movl $10, %ecx
	rep movsb
	pushl $stringHolder
	pushl $MostraBairro
	call printf
	addl $8, %esp
	
	popl %eax               # for backup
	addl $10, %eax
	pushl %eax              # for backup	



	movl (%eax), %ebx       # NumQuartos
	pushl %ebx
	pushl $MostraQuartos
	call printf
	add $8, %esp

	popl %eax               # for backup
	addl $4, %eax
	pushl %eax              # for backup

	movl (%eax), %ebx # numSuites
	pushl %ebx
	pushl $MostraSuites
	call printf
	add $8, %esp

	popl %eax               # for backup
	addl $4, %eax
	pushl %eax              # for backup

	movl (%eax), %ebx # cntGaragem
	pushl %ebx
	pushl $MostraGaragem
	call printf
	add $8, %esp

	popl %eax               # for backup
	addl $4, %eax
	pushl %eax              # for backup

	movl (%eax), %ebx # metragem
	pushl %ebx
	pushl $MostraMetragem
	call printf
	add $8, %esp

	popl %eax               # for backup
	addl $4, %eax

	movl (%eax), %ebx # valorAluguel
	pushl %ebx
	pushl $MostraAlugel
	call printf
	add $8, %esp

	pushl $PrintNewLine
	call printf
	add $4, %esp

	popl %eax               # for backup
	RET



_iroLastRecord:
	movl p_struct, %eax
	movl $0, 75(%eax)      # 0 para proximo do novo, significando que nao tem proximo
	movl %eax, 75(%ebx)    # novo para proximo do ultimo
 	jmp _iroEnd

_iroNoRecordsOrLast:
	cmpl $0, %ebx
	jne _iroLastRecord

	movl p_struct, %eax
	movl $0, 75(%eax)      # 0 para proximo do novo, significando que nao tem proximo
	movl %eax, firstStruct # primeiro registro aponta para o novo

	jmp _iroEnd

_iroFirstRecord:
	movl p_struct, %eax
	movl firstStruct, %ebx
	movl %ebx, 75(%eax)    # novo aponta para o primeiro
	movl %eax, firstStruct # primeiro registro aponta para o novo

	jmp _iroEnd

_insereOrdenado:
	cmpl $0, %eax   # caso de nao haver registros em memoria ou ser o ultimo
	je _iroNoRecordsOrLast
	cmpl $0, %ebx   # caso de inserir na primeira posicao
	je _iroFirstRecord

	# caso de inserir no meio da lista
	movl p_struct, %edx
	movl %eax, 75(%edx) # novo aponta para proximo
	movl %edx, 75(%ebx) # anterior aponta para novo

	jmp _iroEnd


# insere o registro em p_struct ordenado baseado em numQuartos + numSuites
# do menor para maior 
InsereRegistroOrdenado:
	movl firstStruct, %eax
	movl $0, %ebx
_iroLoop:
	cmpl $0, %eax        # caso eax seja 0 quer dizer que acabou os registros
	je _insereOrdenado   # entao insere no final

	pushl %eax
	pushl %ecx

	movl p_struct, %eax
	movl 55(%eax), %edx
	movl 59(%eax), %ecx
	addl %ecx, %edx

	popl %ecx
	popl %eax

	# compara numQuartos + numSuites
	# caso seja menor, continua procurando
	# caso seja maior, eh ali que inserimos
	# CompararQuartos ->   %edx %edx eh o valor do reg que queremos inserir
	
	call CompararQuartos   # %eax eh o reg atual na procura
	jg _insereOrdenado
	movl %eax, %ebx         # salva anterior em ebx
	call ProximoRegistro    # prox em %eax
	jmp _iroLoop
_iroEnd:
	RET



CarregaRegistroDoBufferParaMemoria:
	call _AlocaMemoriaParaRegistro
	call _PassaDadosParaStruct
	call InsereRegistroOrdenado

	#limpa buffer por garantia
	movl bufferMaxSize, %ecx
	leal buffer, %edi
	call eraseStringGeneric

	# caso seja o primeiro registro, nao temos um ponteiro
	# caso tenha, entao o ultimo registro aponta para este novo

	RET 

CarregarRegistrosDoDisco:
	# le e mantem o ponteiro no final da linha lida

	# eax holds the number of bytes read by syscall 3 (read)
	# so we can use it to know if there are any more records in txt
	# readrecord, if readrecordbytes != 0 add record else stop loading


	# open "registros.txt" for rd wr and return the file handle at 'fileHandle'
	#call AbrirArquivoParaEscrita
	call AbrirArquivoParaLeitura

	# loads all records in registros.txt until 0 bytes is read
	# which means we dont have any more records to load
_startRecordLoading:
	# read next line in registros.txt
	# number of read bytes in eax, if 0 stop loading

	call _lerProximoRegistro
	cmpl $0, %eax
	je _finalRecordLoading
	call CarregaRegistroDoBufferParaMemoria
	incl numeroTotalRegistros
	jmp _startRecordLoading
_finalRecordLoading:

	# close the file
	call _fechaArquivos

    RET


CarregaRegistroDoInputParaMemoria:
	movl p_struct, %eax

	# copia nome, 20 chars
	leal nome, %esi
	leal (%eax), %edi
	call CopyStringStringInputToStruct
	movl $20, %ecx
	leal nome, %edi
	call eraseStringGeneric

	# copia telefone, 11 chars
	leal celular, %esi
	leal 20(%eax), %edi 
	call CopyStringStringInputToStruct
	movl $11, %ecx
	leal celular, %edi
	call eraseStringGeneric

	# copia tipoImovel, 4 bytes
	movl tipoImovel, %edx
	movl %edx, 31(%eax)

	# copia enderecoCdd, 10 chars
	leal enderecoCdd, %esi
	leal 35(%eax), %edi
	call CopyStringStringInputToStruct
	movl $10, %ecx
	leal enderecoCdd, %edi
	call eraseStringGeneric

	# copia enderecoBrr, 10 chars
	leal enderecoBrr, %esi
	leal 45(%eax), %edi
	call CopyStringStringInputToStruct
	movl $10, %ecx
	leal enderecoBrr, %edi
	call eraseStringGeneric

	# copia numQuartos, 4 bytes
	movl numQuartos, %edx
	movl %edx, 55(%eax)

	# copia numSuites, 4 bytes
	movl numSuites, %edx
	movl %edx, 59(%eax)

	# copia cntGaragem, 4 bytes
	movl cntGaragem, %edx
	movl %edx, 63(%eax)

	# copia metragem, 4 bytes
	movl metragem, %edx
	movl %edx, 67(%eax)

	# copia valorAluguel, 4 bytes
	movl valorAluguel, %edx
	movl %edx, 71(%eax)
	
	RET




_itcLowTen:
	cmpl $0, %ecx
	je _lowtenEnd
	pushl %eax
	movb %cl, %al
	addb $48, %al
	stosb
	popl %eax
_lowtenEnd:
	movb %dl, %al
	addb $'0', %al
	stosb
	jmp _itcEnd

_itcLowHundred:
	pushl %eax
	movb %cl, %al
	addb $48, %al
	stosb
	popl %eax
	movl $0, %ecx

	cmpl $0, %edx
	jne _pastLowHundred
	pushl %eax
	movb $48, %al
	stosb
	popl %eax

_pastLowHundred:
	cmpl $10, %edx
	jl _itcLowTen
	subl $10, %edx
	incl %ecx
	jmp _pastLowHundred

_itcLowThousand:
	subl $100, %edx
	incl %ecx
	cmpl $100, %edx
	jl _itcLowHundred
	jmp _itcLowThousand

# transforma o numero em %edx em string e guarda em %edi
IntToChar:

	pushl %eax
	pushl %ebx
	pushl %ecx
	
	movl $0, %ecx
	movl $0, %ebx

	cmpl $10, %edx
	jl _itcLowTen

	cmpl $100, %edx
	jl _pastLowHundred

	cmpl $1000, %edx
	jl _itcLowThousand

_itcEnd:
	popl %ecx
	popl %ebx
	popl %eax
	RET





# copia struct em %eax para o buffer
CopiaStructParaBuffer:
	pushl %eax
	pushl %ecx
	pushl %edi
	pushl %esi

	leal buffer, %edi
	movl bufferMaxSize, %ecx
	call memset

	leal buffer, %edi

	leal (%eax), %esi
	movl $20, %ecx
	call CopyStringSelect

	pushl %eax
	movb $124, %al    # 124 = '|'
	stosb
	popl %eax

	addl $20, %eax
	leal (%eax), %esi
	movl $11, %ecx
	call CopyStringSelect

	pushl %eax
	movb $124, %al    # 124 = '|'
	stosb
	popl %eax

	addl $11, %eax
	movl (%eax), %edx
	call IntToChar

	pushl %eax
	movb $124, %al    # 124 = '|'
	stosb
	popl %eax

	addl $4, %eax
	leal (%eax), %esi
	movl $10, %ecx
	call CopyStringSelect

	pushl %eax
	movb $124, %al    # 124 = '|'
	stosb
	popl %eax

	addl $10, %eax
	leal (%eax), %esi
	movl $10, %ecx
	call CopyStringSelect

	pushl %eax
	movb $124, %al    # 124 = '|'
	stosb
	popl %eax

	addl $10, %eax
	movl (%eax), %edx
	call IntToChar

	pushl %eax
	movb $124, %al    # 124 = '|'
	stosb
	popl %eax

	addl $4, %eax
	movl (%eax), %edx
	call IntToChar

	pushl %eax
	movb $124, %al    # 124 = '|'
	stosb
	popl %eax
	addl $4, %eax
	movl (%eax), %edx
	call IntToChar

	pushl %eax
	movb $124, %al    # 124 = '|'
	stosb
	popl %eax

	addl $4, %eax
	movl (%eax), %edx
	call IntToChar

	pushl %eax
	movb $124, %al    # 124 = '|'
	stosb
	popl %eax

	addl $4, %eax
	movl (%eax), %edx
	call IntToChar

	leal buffer, %edi
	addl $86, %edi
	movb $10, %al
	stosb


	popl %esi
	popl %edi
	popl %ecx
	popl %eax
	RET


AbrirArquivoParaLeitura:
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edx
	


	movl $5, %eax              # sys call for open
    movl $fileName, %ebx       # file name
    movl $02, %ecx          # flags, read write
    movl $0744, %edx           # permissions
    int $0x80 

    test %eax,%eax         
    js _badfile            

    movl %eax, fileHandle

	popl %edx
	popl %ecx
	popl %ebx
	popl %eax
	RET

AbrirArquivoParaEscrita:
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edx
	


	movl $5, %eax              # sys call for open
    movl $fileName, %ebx       # file name
    movl $01002, %ecx          # flags, read write
    movl $0744, %edx           # permissions
    int $0x80 

    test %eax,%eax         
    js _badfile            

    movl %eax, fileHandle

	popl %edx
	popl %ecx
	popl %ebx
	popl %eax
	RET


# escreve registro salvo em buffer
# no arquivo registros.txt
EscreveRegistroNoDisco:
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edx


    movl $4, %eax              # system call for write
    movl fileHandle, %ebx      # file handle
    movl $buffer, %ecx         # buffer
    movl bufferMaxSize, %edx   # buffer length
    int $0x80                  # call kernel

    test %eax,%eax             # check for an error, if %eax is neg
    js _badfile                # if error
    
	popl %edx
	popl %ecx
	popl %ebx
	popl %eax

	RET





ReescreverRegistrosNoArquivo:
	movl firstStruct, %eax

	# abre arquivo para escrita
	call AbrirArquivoParaEscrita
	movl numeroTotalRegistros, %ecx
_rraLoop:

	call CopiaStructParaBuffer
	call EscreveRegistroNoDisco
	call ProximoRegistro
	loop _rraLoop

	# fecha o arquivo de escrita
	call _fechaArquivos
	RET






# considerando o registro atual em %eax
# passa para o proximo registro e guarda em %eax
ProximoRegistro:
	movl 75(%eax), %eax
	RET
# compara se o registro atual em %eax tem o numero de quartos simples e suites
# que o valor em %edx
CompararQuartos:
	pushl %ebx
	pushl %ecx
	
	movl 55(%eax), %ebx    # quartos simples
	movl 59(%eax), %ecx    # suites
	addl %ebx, %ecx
	cmpl %edx, %ecx
	
	popl %ecx
	popl %ebx

	RET



PegarInput:
	pushl   $InputPrintNome
	call    printf
	add $4, %esp

	pushl	$nome
	pushl	$tipoString
	call	scanf
	add $8, %esp


	pushl   $InputPrintCelular
	call    printf
	add $4, %esp

	pushl	$celular
	pushl	$tipoString
	call	scanf
	add $8, %esp


	pushl   $InputPrintImovel
	call    printf
	add $4, %esp

	pushl	$tipoImovel
	pushl	$tipoInt
	call	scanf
	add $8, %esp


	pushl   $InputPrintCidade
	call    printf
	add $4, %esp

	pushl	$enderecoCdd
	pushl	$tipoString
	call	scanf
	add $8, %esp


	pushl   $InputPrintBairro
	call    printf
	add $4, %esp

	pushl	$enderecoBrr
	pushl	$tipoString
	call	scanf
	add $8, %esp


	pushl   $InputPrintQuartos
	call    printf
	add $4, %esp

	pushl	$numQuartos
	pushl	$tipoInt
	call	scanf
	add $8, %esp


	pushl   $InputPrintSuites
	call    printf
	add $4, %esp

	pushl	$numSuites
	pushl	$tipoInt
	call	scanf
	add $8, %esp


	pushl   $InputPrintGaragem
	call    printf
	add $4, %esp

	pushl	$cntGaragem
	pushl	$tipoInt
	call	scanf
	add $8, %esp


	pushl   $InputPrintMetragem
	call    printf
	add $4, %esp

	pushl	$metragem
	pushl	$tipoInt
	call	scanf
	add $8, %esp


	pushl   $InputPrintAlugel
	call    printf
	add $4, %esp

	pushl	$valorAluguel
	pushl	$tipoInt
	call	scanf
	add $8, %esp

	

	RET



RecebeInputBusca:
	pushl	$PrintBusca
	call	printf
	add $4, %esp
	movl $0, buscaQuantidadeQuartos
	pushl   $buscaQuantidadeQuartos
	pushl   $tipoInt
	call    scanf
	add $8, %esp
	RET

RecebeInputRemove:
	pushl   $PrintRemove
	call    printf
	add $4, %esp

	pushl	$RemoveCelularStringHolder
	pushl	$tipoString
	call	scanf
	add $8, %esp
	RET


ComparaCelular:
	pushl %esi
	pushl %edi
	pushl %eax
	movl $11, %ecx

	leal 20(%eax), %esi
	leal RemoveCelularStringHolder, %edi
_ccLoop:
	lodsb
	cmpb (%edi), %al
	jne _ccEnd
	inc %edi
	loop _ccLoop
_ccEnd:
	cmpl $0, %ecx
	popl %eax
	popl %edi
	popl %esi
	RET



Menu:
	pushl	$opcoes
	call	printf
	add $4, %esp
	
	# zera a variavel opcao para evitar conflitos
	# movl $0, opcao

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
	call _AlocaMemoriaParaRegistro
	call CarregaRegistroDoInputParaMemoria
	call InsereRegistroOrdenado

	incl numeroTotalRegistros


	jmp Menu

_firstRecordCase:

	movl 75(%eax), %ecx
	movl %ecx, firstStruct
	jmp _rrEnd

_notFirstRecordCase:
	movl 75(%eax), %edx
	movl %edx, 75(%ebx)
	jmp _rrEnd

_removeRecord:
	pushl %eax
	pushl %ebx

	popl %ebx
	popl %eax

	# caso o registro a ser removido seja o primeiro
	# o antes dele eh 0 e o primeiro eh firstStruct
	cmpl $0, %ebx
	je _firstRecordCase
	jmp _notFirstRecordCase
_rrEnd:
	pushl %eax
	call free
	add $4, %esp

	jmp Menu

# remove baseado no numero de celular do cadastro
Remover:
	pushl 	$removerTexto
	call	printf
	add $4, %esp

	# salva o num de celular em RemoveCelular
	call RecebeInputRemove
	
	movl firstStruct, %eax
	movl $0, %ebx
_removeLoop:
	cmpl $0, %eax        # caso eax seja 0 quer dizer que acabou os registros
	je _recordNotFound

	# compara os num de celular do remove com cada registro
	# remove a 1 ocorrencia do numero de celular
	call ComparaCelular
	je _removeRecord
	movl %eax, %ebx         # salva anterior em ebx
	call ProximoRegistro    # prox em %eax
	jmp _removeLoop

	decl numeroTotalRegistros

	jmp Menu


_recordNotFound:
	pushl $PrintRecordNotFound
	call printf
	add $4, %esp
	jmp Menu
_recordFound:
	call MostraRegistro
	call ProximoRegistro
	jmp _searchLoop
Consultar:
	pushl	$consultarTexto
	call	printf
	add $4, %esp

	# pega o numero de quartos simples + suites
	# e guarda em buscaQuantidadeQuartos
	call RecebeInputBusca
	movl buscaQuantidadeQuartos, %edx    # para usar em CompararQuartos

	# 1 registro em eax, caso seja 0 quer dizer que nao há registros na memoria
	movl firstStruct, %eax
	cmpl $0, %eax
	je _recordNotFound
_searchLoop:
	cmpl $0, %eax        # caso eax seja 0 quer dizer que acabou os registros
	je _recordNotFound

	call CompararQuartos
	je _recordFound
	call ProximoRegistro
	jmp _searchLoop

	jmp Menu

Relatorio:
	pushl	$relatorioTexto
	call	printf
	add $4, %esp
	
	pushl $PrintNewLine
	call printf
	add $4, %esp

	movl firstStruct, %eax
_ListAllLoop:
	cmpl $0, %eax
	je _ListAllLoopEnd

	call MostraRegistro
	call ProximoRegistro
	jmp _ListAllLoop
_ListAllLoopEnd:

	jmp Menu

