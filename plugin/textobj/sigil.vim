
if exists('g:loaded_textobj_sigil')
  finish
endif

let g:loaded_textobj_sigil = 1

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
    let char = l[col('.') - 1]
    if (char =~ '[\$@%&*]')
        let sigil_found = 1
        let b = getpos('.')
    endif

    while col('.') != 1
      let char = l[col('.') - 1]
      if (char =~ '[\$@%&*]')
        let sigil_found = 1
        let b = getpos('.')
        break
      endif
      normal! h
    endwhile

    if (!sigil_found)
      echo 'sigil not found!'
      return 0
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
        if (poped == '[')
          if (char != ']')
            echo 'illegal braces match!'
            return 0
          endif
        elseif (poped == '{')
          if (char != '}')
            echo 'illegal braces match!'
            return 0
          endif
        elseif (poped == '(')
          if (char != ')')
            echo 'illegal braces match!'
            return 0
          endif
        endif

        let last_brace_pos = s:get_prev_pos()
        continue
      endif


      "" check end character or not
      if (len(braces) >= 1)
        " allow space
        if (char =~ '[,;]')
          let e = s:get_prev_pos()
          let end_found = 1
          break
        endif
      else
        if (char =~ '[ ,;]')
          let e = s:get_prev_pos()
          let end_found = 1
          break
        endif
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

