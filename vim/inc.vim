let g:incdir = ''
let g:incdir = g:incdir . ' +incdir+/home/gizaneko/proj/srvio/./common'
let g:incdir = g:incdir . ' +incdir+/home/gizaneko/proj/srvio/./cpu/include'
let g:incdir = g:incdir . ' +incdir+/home/gizaneko/proj/srvio/./cpu/test/include'
let g:incdir = g:incdir . ' +incdir+/home/gizaneko/proj/srvio/./pm/include'
let g:incdir = g:incdir . ' +incdir+/home/gizaneko/proj/srvio/./pm/test'

" append compiler option
if !exists('g:syntastic_verilog_compiler_options')
	let g:syntastic_verilog_compiler_options = '-Wall '
endif
let g:syntastic_verilog_compiler_options = 
	\g:syntastic_verilog_compiler_options . g:incdir

if !exists('g:syntastic_systemverilog_compiler_options')
	let g:syntastic_systemverilog_compiler_options = '-sv -Wall '
endif
let g:syntastic_systemverilog_compiler_options = 
	\g:syntastic_systemverilog_compiler_options . g:incdir