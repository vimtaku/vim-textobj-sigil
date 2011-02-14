
if exists('g:loaded_textobj_sigil')
  finish
endif

let g:loaded_textobj_sigil = 1

call textobj#user#plugin('sigil', {
		\   'sigil_a': {
		\     '*pattern*': '[$@%]\+[^ ,]\+',
		\     'select': ['ag'],
		\   },
		\   'sigil_i': {
		\     '*pattern*': '[$@%]\+[_a-zA-Z]\+',
		\     'select': ['ig'],
		\   }})

" match $$like->{'hoge'} or %hoge
