if !has('nvim')
  finish
endif

" Default mappings for relatedfiles plugin
" To disable default mappings, set g:related_no_default_mappings = 1 in your vimrc

if exists('g:related_no_default_mappings')
  finish
endif


" Define <Plug> targets and set defaults in a loop
let s:mappings = [
      \ ['<Leader>r', 'Find', 'false'],
      \ ['<Leader>R', 'Create', 'true'],
      \ ['<Leader>rt', 'FindTest', "false, 'test'"],
      \ ['<Leader>rT', 'CreateTest', "true, 'test'"],
      \ ['<Leader>rr', 'FindSource', "false, 'source'"],
      \ ['<Leader>rR', 'CreateSource', "true, 'source'"],
      \ ['<Leader>rm', 'FindMain', "false, 'main'"],
      \ ['<Leader>rM', 'CreateMain', "true, 'main'"],
      \ ['<Leader>rb', 'FindBuild', "false, 'build'"],
      \ ['<Leader>rB', 'CreateBuild', "true, 'build'"],
      \ ]

for s:m in s:mappings
  let s:lhs = s:m[0]
  let s:target = s:m[1]
  let s:args = s:m[2]
  
  execute 'nnoremap <silent> <Plug>Related' . s:target . ' :lua require("related").find(' . s:args . ')<CR>'
  
  if !hasmapto('<Plug>Related' . s:target, 'n') && maparg(s:lhs, 'n') == ''
    execute 'nmap ' . s:lhs . ' <Plug>Related' . s:target
  endif
endfor
