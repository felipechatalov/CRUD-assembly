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

	opcao: .int 0
	tipoInt: .asciz "%d"




	fileName: .asciz "registros.txt"
    testFileName: .asciz "test.txt"
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
    movl $150, %edx            # buffer length
    int $0x80                  # call kernel

    test %eax,%eax             # check for an error, if %eax is neg
    js _badfile                 # if error
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

    call _writeBufferToTestFile

    RET

CarregarRegistrosDoDisco:
    # open "registros.txt" for rd wr and return the file handle at 'fileHandle'
    call _abreArquivoRDWR
    # read the next record and hold it in 'buffer'
    call _lerProximoRegistro

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
































