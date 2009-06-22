@Polar_Plot_Data
@Get_Sky_Data
@Map_Plot_Data
@Polar_Surface_Plot


PRO VISUALISE_DATA, list_index, MAP=MAP, POLAR=POLAR, SURFACE=SURFACE
  line_nums_array = [2, 108, 268, 431, 926, 1523, 1749, 2027]
  line_number = line_nums_array[list_index]
  print, line_number
  GET_SKY_DATA, line_number, azimuths=azimuths, zeniths=zeniths, dns=dns

  IF keyword_set(map) THEN BEGIN
    MAP_PLOT_DATA, azimuths, zeniths, dns
  ENDIF ELSE IF keyword_set(polar) THEN BEGIN
    Polar_Plot_Data, azimuths, zeniths, dns
  ENDIF ELSE IF keyword_set(surface) THEN BEGIN
    POLAR_SURFACE_PLOT, azimuths, zeniths, dns
  ENDIF
END

PRO SKY_RADIANCE_GUI_EVENT, EVENT
  print, "Event Detected"
  
  ; Get the info structure from the uvalue of the base widget
  widget_control, event.top, get_uvalue=infoptr
  info = *infoptr
  
  ; Get the uvalue of the widget that caused the event
  widget_control, event.id, get_uvalue=widget
  
  if (STRPOS(widget, "List") ne -1) THEN BEGIN
    info.list_index = event.index
    print, info.list_index
  endif
  
  if (STRPOS(widget, "Button") ne -1) THEN BEGIN   
    info.type = widget
    
    help, info.list_index
    
    CASE widget OF
      "MapButton": Visualise_Data, info.list_index, /MAP
      "PolarButton": Visualise_Data, info.list_index, /POLAR
      "SurfaceButton": Visualise_Data, info.list_index, /SURFACE
    ENDCASE
  ENDIF
  
  *infoptr = info
END

PRO SKY_RADIANCE_GUI
  base = widget_base(row=2)
  
  ;text_line = widget_text(base, /editable, uvalue="TextBox")
  wavelength_list = string([340, 380, 440, 500, 675, 870, 939, 1020])
  list = widget_list(base, value=wavelength_list, ysize=8, uvalue="List")
  
  button_base = widget_base(base, row=1)
  button_map = widget_button(button_base, value="Show Map Plot", uvalue="MapButton")
  button_polar = widget_button(button_base, value="Show Polar Plot", uvalue="PolarButton")
  button_surface = widget_button(button_base, value="Show Surface Plot", uvalue="SurfaceButton")
  
  info = {list:list, type:'', wavelength:'', list_index:''}
  print, "ListIndex = ", info.list_index
  infoptr = ptr_new(info)
  
  widget_control, base, set_uvalue=infoptr
  
  widget_control, base, /realize
  
  xmanager, 'sky_radiance_gui', base, /no_block
END