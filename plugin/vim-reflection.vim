function! ReflectionsMap(key)
  let escaped_key = substitute(a:key, "'", "''", 'g')
  execute 'inoremap <buffer> <silent> '.a:key." <C-R>=vim_reflection#ReflectionsInsert('".escaped_key."')<CR>"
endfunction

function! ReflectionsInit()
  if exists('b:autopairs_loaded')
    return
  end
  let b:autopairs_loaded = 1
  let g:Reflections      = {'(': ')', '[': ']', '{': '}', "'": "'", '"': '"', '`': '`'}

  for [open, close] in items(g:Reflections)
    call ReflectionsMap(open)
    if open != close
      call ReflectionsMap(close)
    end
  endfor

  execute 'inoremap <script> <buffer> <silent> <CR> <CR><SID>vim_reflection#ReflectionsReturn'
  execute 'inoremap <buffer> <silent> <BS> <C-R>=vim_reflection#ReflectionsDelete()<CR>'
  execute 'inoremap <buffer> <silent> <C-H> <C-R>=vim_reflection#ReflectionsDelete()<CR>'
endfunction

inoremap <silent> <SID>vim_reflection#ReflectionsReturn <C-R>=vim_reflection#ReflectionsReturn()<CR>
imap <script> <Plug>vim_reflection#ReflectionsReturn <SID>vim_reflection#ReflectionsReturn

au BufEnter * :call ReflectionsInit()
