
if exists('g:loaded_textobj_sigil')
  finish
endif

let g:loaded_textobj_sigil = 1

let s:BRACE_MAP = {
\'(' : ')'
\, '{' : '}'
\, '[' : ']'
\}

call textobj#user#plugin('sigil', {
\   'i': {
\     '*pattern*': '[$@%&*][_a-zA-Z0-9]\+',
\     'select': ['ig'],
\   },
\   '-': {
\     '*sfile*': expand('<sfile>:p'),
\     'select-a': 'ag',
\     '*select-a-function*': 's:select_a',
\   }
\})

function! s:select_a()  "{{{2
  let save_ww = &whichwrap
  set whichwrap=h,l

  try
    let c = getpos('.')
    let [b, e] = [c, c]

    let sigil_found = 0
    let l = getline('.')

    " first character check
    let char = l[col('.') - 1]
    if (char =~ '[\$@%&*]')
        let sigil_found = 1
        let b = getpos('.')
    endif

    while col('.') != 1
      let col = col('.')

      " check cursor character
      let char = l[col - 1]
      if (char =~ '[\$@%&*]')
        let sigil_found = 1
        let b = getpos('.')
        break
      endif

      if (col == 2)
          " check first character of line.
          let char = l[col - 2]
          if (char =~ '[\$@%&*]')
            let sigil_found = 1
            let b = s:get_prev_pos()
            break
          endif
      endif

      normal! h
    endwhile

    if (!sigil_found)
      return s:show_error('sigil not found!')
    endif

    call cursor(b[1], b[2])


    let braces = []
    let end_found = 0
    let last_brace_pos = [b[0], b[1], b[2]-1, b[3]]
    let last_char_pos  = last_brace_pos
    while (col('.') != col('$') - 1)
      normal! l
      let char = l[col('.') - 1]
      let last_char_pos = s:get_prev_pos()

      "" if open brace
      if (char =~ '[{\[(]')
        call add(braces, char)
        continue
      endif

      "" if close brace
      if (char =~ '[}\])]')

        if (len(braces) < 1)
          let e = last_char_pos
          break
        endif

        let poped = remove(braces, -1)

        if (s:is_brace(poped) && !s:is_match_brace(poped, char))
          return s:show_error('illegal braces match!')
        endif

        let last_brace_pos = getpos('.')
        continue
      endif


      "" allow space during braces
      let find_endchar_regex = (len(braces) >= 1) ? '[,;]' : '[ ,;]'

      "" check end character or not
      if (char =~ find_endchar_regex)
          let e = s:get_prev_pos()
          let end_found = 1
          break
      endif

      "" this plugin only allow a line.
      if (s:is_eol())
          let e = getpos('.')
          let end_found = 1
          break
      endif
    endwhile

    if (!end_found)
        " which col is bigger?
        if (last_brace_pos[2] >= last_char_pos[2])
          let e = last_brace_pos
        else
          let e = last_char_pos
        endif 
    endif

  finally
    let &whichwrap = save_ww
  endtry

  return ['v', b, e]
endfunction

function! s:get_prev_pos()
  let pos = getpos('.')
  return [pos[0], pos[1], pos[2] -1, pos[3]]
endfunction

function! s:is_brace(char)
    return (a:char =~ '[{\[()\]}]') ? 1 : 0
endfunction

function! s:is_match_brace(open, close)
    if has_key(s:BRACE_MAP, a:open) && (s:BRACE_MAP[ a:open ] == a:close)
        return 1
    endif
    return 0
endfunction

function! s:show_error(msg)
    echoerr a:msg
    return 0
endfunction

function! s:is_eol()
  return strlen(getline('.')) == col('.') ? 1 : 0
endfunction

function! s:str2bytes(str)
  return map(range(len(a:str)), 'char2nr(a:str[v:val])')
endfunction


