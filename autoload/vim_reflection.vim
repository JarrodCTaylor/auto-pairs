function! vim_reflection#ReflectionsInsert(key)
  let current_line                       = getline('.')
  let current_pos_in_line                = col('.') - 1
  let string_of_characters_before_cursor = strpart(current_line, 0, current_pos_in_line)
  let character_under_cursor             = get(split(strpart(current_line, current_pos_in_line), '\zs'), 0, '')
  let previous_character                 = get(split(string_of_characters_before_cursor, '\zs'), -1, '')

  " We do not want to add a closing pair to escaped characters
  if previous_character == '\'
    return a:key
  end

  " This would be a closing bracket ), ] or }
  if !has_key(g:Reflections, a:key)
    " The user is moving past the closing bracket
    if character_under_cursor == a:key
      return "\<Right>"
    end
    " The user is inserting an orphan closing bracket
    return a:key
  end

  let open = a:key
  let close = g:Reflections[open]

  " Don't reflect if odd number of ticks on line
  if  index(['"', "'", '`'], "'") != -1
    let list_of_current_line = split(current_line, '\zs')
    let key_count = count(list_of_current_line, a:key)
    if key_count % 2 != 0 && key_count != 0
        return open."\<Right>"
    end
  end

  " This is for keys that are the same opening and closing `, ", '
  if character_under_cursor == close && open == close
    return "\<Right>"
  end

  " Correctly deal with triple ticks `, ", '
  if open == close
    let pprev_char = current_line[col('.')-3]
    if pprev_char == open && previous_character == open
      " Double pair found
      return repeat(a:key, 4) . repeat("\<LEFT>", 3)
    end
  end

  " In vim files if the first character on a line is " leave it alone
  if &filetype == 'vim' && a:key == '"'
    if string_of_characters_before_cursor =~ '^\s*$'
      return a:key
    end
  end

  return open.close."\<Left>"
endfunction

function! vim_reflection#ReflectionsDelete()
  let current_line                 = getline('.')
  let current_pos_in_line          = col('.') - 1
  let list_of_previous_characters  = split(strpart(current_line, 0, current_pos_in_line), '\zs')
  let character_before_cursor      = get(list_of_previous_characters, -1, '')
  let two_characters_before_cursor = get(list_of_previous_characters, -2, '')

  " If character was escaped no action needs to be taken
  if two_characters_before_cursor == '\'
    return "\<BS>"
  end

  " If we are deleting an opening character
  if has_key(g:Reflections, character_before_cursor)
    let close = g:Reflections[character_before_cursor]
    " If the closing character is on the same line as cursor
    if match(current_line, '^\s*' . close, current_pos_in_line) != -1
      " The amount of white space between the opening and closing characters
      let space = matchstr(current_line, '^\s*', current_pos_in_line)
      " Delete the opening character the number of spaces until the closing
      " character and the closing character itself.
      return "\<BS>". repeat("\<DEL>", len(space) + 1)
    " Else if the closing character is not on the same line as a cursor
    elseif match(current_line, '^\s*$', current_pos_in_line) != -1
      let nline = getline(line('.') + 1)
      " If the closing character is on the line below the cursor
      if nline =~ '^\s*' . close
        " In Vim " is the comment character so we backspace normally over them
        if &filetype == 'vim' && character_before_cursor == '"'
          return "\<BS>"
        end
        " The amount of white space from the beginning of the line below the
        " cursor to closing brace
        let space = matchstr(nline, '^\s*')
        return "\<BS>\<DEL>". repeat("\<DEL>", len(space) + 1)
      end
    end
  end
  " We are deleting a closing character backspace as normal
  return "\<BS>"
endfunction

function! vim_reflection#ReflectionsReturn()
  let current_line           = getline('.')
  let line_above_cursor      = getline(line('.')-1)
  let prev_char              = line_above_cursor[strlen(line_above_cursor)-1]
  let character_under_cursor = current_line[col('.')-1]

  " If previous character is a opener and closer is under cursor
  if has_key(g:Reflections, prev_char) && g:Reflections[prev_char] == character_under_cursor
      return "\<ESC>=ko"
  end
  return ''
endfunction
