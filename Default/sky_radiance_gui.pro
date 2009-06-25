@Polar_Plot_Data
@Get_Sky_Data
@Map_Plot_Data
@Polar_Surface_Plot

PRO SET_BROWSED_TEXT, infoptr
  info = *infoptr

  directory = dialog_pickfile(/DIRECTORY)
  widget_control, info.text_dirname, set_value=directory
   
  info.dirname = directory
  
  *infoptr = info
END


PRO VISUALISE_DATA, dirname, list_index, normalise=normalise, MAP=MAP, POLAR=POLAR, SURFACE=SURFACE
  print, "Normalise is " + string(normalise)

  line_nums_array = [2, 108, 268, 431, 926, 1523, 1749, 2027]
  line_number = line_nums_array[list_index]
  
  wavelengths_array = [" 340", " 380", " 440", " 500", " 675", " 870", " 939", " 1020"]
  
  print, line_number
  GET_SKY_DATA, dirname, line_number, azimuths=azimuths, zeniths=zeniths, dns=dns, normalise=normalise

  IF keyword_set(map) THEN BEGIN
    MAP_PLOT_DATA, azimuths, zeniths, dns, "Sky Radiance Distribution: " + FILE_BASENAME(dirname) + wavelengths_array[list_index] + "nm"
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
  
  print, widget
  
  help, event, /structure
  
  if (STRPOS(widget, "List") ne -1) THEN BEGIN
    info.list_index = event.index
    *infoptr = info
    print, info.list_index
  ENDIF ELSE IF (STRPOS(widget, "Checkbox") ne -1) THEN BEGIN
    info.normalise = event.select
    *infoptr = info
  ENDIF ELSE IF (STRPOS(widget, "Button") ne -1) THEN BEGIN   
    CASE widget OF
      "MapButton": Visualise_Data, info.dirname, info.list_index, normalise=info.normalise, /MAP
      "PolarButton": Visualise_Data, info.dirname, info.list_index, normalise=info.normalise ,/POLAR
      "SurfaceButton": Visualise_Data, info.dirname, info.list_index, normalise=info.normalise, /SURFACE
      "BrowseButton": Set_Browsed_Text, infoptr
    ENDCASE
  ENDIF
  
  print, info.text_dirname
  
  
END

PRO SKY_RADIANCE_GUI
  loadct, 13
  
  base = widget_base(row=3)
  
  filename_base = widget_base(base, col=3)
  label_dirname = widget_label(filename_base, value="Directory:")
  text_dirname = widget_text(filename_base, uvalue="FilenameText", xsize=100)
  button_browse = widget_button(filename_base, value="Browse", uvalue="BrowseButton")
  
  parameters_base = widget_base(base, col=3)
  label_wavelengths = widget_label(parameters_base, value="Wavelength:")
  wavelength_list = string([340, 380, 440, 500, 675, 870, 939, 1020])
  list = widget_list(parameters_base, value=wavelength_list, ysize=8, uvalue="List")
  
  checkbox_base = widget_base(parameters_base, /NONEXCLUSIVE)
  checkbox_normalise = widget_button(checkbox_base, value="Normalise", uvalue="NormaliseCheckbox")
  
  button_base = widget_base(base, row=1)
  button_map = widget_button(button_base, value="Show Map Plot", uvalue="MapButton")
  button_polar = widget_button(button_base, value="Show Polar Plot", uvalue="PolarButton")
  button_surface = widget_button(button_base, value="Show Surface Plot", uvalue="SurfaceButton")
  
  ; Set up info structure
  info = {normalise:0, dirname:'', text_dirname:text_dirname, list:list, type:'', wavelength:'', list_index:''}
  
  print, "ListIndex = ", info.list_index
  infoptr = ptr_new(info)
  
  widget_control, base, set_uvalue=infoptr
  
  widget_control, base, /realize
  
  xmanager, 'sky_radiance_gui', base, /no_block
END