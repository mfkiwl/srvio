#SystemVerilog vim Environment
## vim plug-in manager

## Syntax Checking with syntastic
### syntastic
[syntastic] is one of popular syntax checking plug-in for vim.  
syntastic only supports verilog filetype by default(https://github.com/vim-syntastic/syntastic/pull/759), due to lack of systemverilog support of vim back then.  
If you use syntastic with systemverilog, introducing dedicated systemverilog checker instead of reusing verilog checker is recommended.
In order to add systemverilog filetype to syntastic, see the following guide.

[syntastic]: https://github.com/vim-syntastic/syntastic

###Add systemverilog checker to syntastic
1. Copy "systemverilog" directory to syntastic/syntax_checkers under your vim plug-in installation directory
2. Add following member to "s:\_DEFAULT_CHECKERS" in syntastic/plugin/syntastic/registry.vim
```
\ 'systemverilog': ['verilator'],
```
Modified registry.vim looks like folloging example.
```
let s:_DEFAULT_CHECKERS = {
        \ 'actionscript':  ['mxmlc'],
		...
		...
        \ 'zsh':           ['zsh'],
        \ 'systemverilog': ['verilator'],
    \}
```

## Keyword matching
matchit.vim plug-in is very useful to write large scale and complex RTL codes.  
It allows jump across a block between begin and end, case and endcase, and so forth.  
Following setting is one example for keyword pairs.
```
runtime macros/matchit.vim
au Filetype verilog let b:match_words =                                     
            \'\<if\>:\<else\>,'.
            \'\<begin\>:\<end\>,'.
            \'\<task\>:\<endtask\>,'.
            \'\<function\>:\<endfunction\>,'.
            \'\<case\>\|\<casex\>\|\<casez\>:\<endcase\>,'.
            \'\<module\>:\<endmodule\>,'.
            \'\<generate\>:\<endgenerate\>,'.
            \ '`ifdef\|`ifndef:`else\|`elsif:`endif'

au Filetype systemverilog let b:match_words =
            \'\<if\>:\<else\>,'.
            \'\<begin\>:\<end\>,'.
            \'\<task\>:\<endtask\>,'.
            \'\<function\>:\<endfunction\>,'.
            \'\<case\>\|\<casex\>\|\<casez\>:\<endcase\>,'.
            \'\<class\>:\<endclass\>,'.
            \'\<module\>:\<endmodule\>,'.
            \'\<interface\>:\<endinter\>,'.
            \'\<generate\>:\<endgenerate\>,'.
            \ '`ifdef\|`ifndef:`else\|`elsif:`endif'
```
