FUNCTION INIT_GRIDTILES_ARRAY
  TileStruct = {x:"", y:""}
  GridTiles = replicate(TileStruct, 7, 13)
  
  ; First column of diagram
  GridTiles[0, 0].x = "S"
  GridTiles[0, 0].y = "V"
  
  GridTiles[0, 7].x = "N"
  GridTiles[0, 7].y = "L"
  
  GridTiles[0, 8].x = "N"
  GridTiles[0, 8].y = "F"
  
  GridTiles[0, 9].x = "N"
  GridTiles[0, 9].y = "A"
  
  ; Second column of diagram
  GridTiles[1, 0].x = "S"
  GridTiles[1, 0].y = "W"
  
  GridTiles[1, 1].x = "S"
  GridTiles[1, 1].y = "R"
  
  GridTiles[1, 2].x = "S"
  GridTiles[1, 2].y = "M"
  
  
  
  GridTiles[4, 3].x = "S"
  GridTiles[4, 3].y = "K"
  
  return, GridTiles
END

FUNCTION EVERY_GRID_BETWEEN, bottom, top
  print, top
  print, bottom
  print, top - bottom
  
  n = bottom / 10000
  
  array = lonarr(10000)
  
  i = 0
  WHILE (n*10000 LT top) DO BEGIN
    ;print, n*10000
    array[i] = n*10000
    n=n+1
    i=i+1
  ENDWHILE
  
  new_array = array[WHERE(array)]
  
  return, new_array
END

FUNCTION GET_LETTERS_FROM_GRIDREF, x, y
  x_First = STRMID(x, 2, 1)
  y_First = STRMID(y, 1, 1)
  
  GridTiles = INIT_GRIDTILES_ARRAY()
  
  Chars = GridTiles[fix(x_First), fix(y_First)]
  
  return, Chars
END

FUNCTION CONVERT_GRIDREF_TO_TILE_REF, x, y
  Chars = GET_LETTERS_FROM_GRIDREF(x, y)
  FirstNum = STRMID(x, 2, 1)
  SecondNum = STRMID(y, 2, 1)
  
  return, Chars.x + Chars.y + STRCOMPRESS(STRING(FirstNum)) + STRCOMPRESS(STRING(SecondNum))
END

; Variables need to be input as strings in order bottom, top, left, right
PRO SELECT_NM_TILES, bl_y, tl_y, bl_x, br_x
  bottom = long(bl_y)
  top = long(tl_y)
  
  left = long(bl_x)
  right = long(br_x)
 
 
  y_intervals = EVERY_GRID_BETWEEN(bottom, top)
  x_intervals = EVERY_GRID_BETWEEN(left, right)
  
  FOR i = 0, N_ELEMENTS(y_intervals) - 1 DO BEGIN
    FOR j = 0, N_ELEMENTS(x_intervals) - 1 DO BEGIN
      print, CONVERT_GRIDREF_TO_TILE_REF(STRCOMPRESS(STRING(x_intervals[j])), STRCOMPRESS(STRING(y_intervals[i])))
    END
  END
    
END