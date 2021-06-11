let g:srcdir = ''
let g:srcdir = g:srcdir . ' -y /home/gizaneko/proj/srvio/./cpu/rtl'
let g:srcdir = g:srcdir . ' -y /home/gizaneko/proj/srvio/./cpu/test/tb'
let g:srcdir = g:srcdir . ' -y /home/gizaneko/proj/srvio/./pm/rtl'
let g:srcdir = g:srcdir . ' -y /home/gizaneko/proj/srvio/./pm/test'

" defines
let g:defines = '+define+VERILATOR '

" simulation options
let g:exopt = '-Wno-fatal '

" append compiler option
if !exists('g:syntastic_verilog_compiler_options')
	let g:syntastic_verilog_compiler_options = '-Wall '
endif
let g:syntastic_verilog_compiler_options = 
	\g:syntastic_verilog_compiler_options . g:srcdir . g:defines . g:exopt

if !exists('g:syntastic_systemverilog_compiler_options')
	let g:syntastic_systemverilog_compiler_options = '-sv -Wall '
endif
let g:syntastic_systemverilog_compiler_options = 
	\g:syntastic_systemverilog_compiler_options . g:srcdir .g:defines . g:exopt
