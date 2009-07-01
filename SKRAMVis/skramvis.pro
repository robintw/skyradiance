; Called when the 'Browse' button is clicked and displays a directory selection dialog
; box, storing the result in the textbox and in the info structure.
PRO SET_BROWSED_TEXT, infoptr
  info = *infoptr

  directory = dialog_pickfile(/DIRECTORY, PATH=info.last_dir_path)
  widget_control, info.text_dirname, set_value=directory
   
  info.dirname = directory
  info.last_dir_path = directory
  
  *infoptr = info
END

; Handler routine called by Sky_Radiance_GUI_Event. Takes a directory name, and a list index
; to select the wavelength used. Takes keywords to decide what type of plot to display
; and whether to normalise the data or not.
PRO VISUALISE_DATA, dirname, list_index, normalise=normalise, MAP=MAP, SURFACE=SURFACE, win_contour_id=win_contour_id, win_image_id=win_image_id, label_dgratio=label_dgratio, image_dir=image_dir, sunshine_file=sunshine_file

  line_nums_array = [2, 108, 268, 431, 926, 1523, 1749, 2027]
  line_number = line_nums_array[list_index]
  
  wavelengths_array = [" 340", " 380", " 440", " 500", " 675", " 870", " 939", " 1020"]
  
  print, line_number
  GET_SKY_DATA, dirname, line_number, azimuths=azimuths, zeniths=zeniths, dns=dns, normalise=normalise, datetime=datetime
  
  print, "Got datetime of: "
  print, datetime, FORMAT='(C(CYI4, 1X, CMOI2, 1X, CDI2, 1X, CHI2, 1X, CMI2, 1X, CSI2))'
  
  wset, win_contour_id
  

  IF keyword_set(map) THEN BEGIN
    time_string = string(datetime, FORMAT='(C(CHI2, ":", CMI2, ":", CSI2))')
    title = "Sky Radiance Distribution: " + FILE_BASENAME(dirname) + " " + time_string + " " + wavelengths_array[list_index] + "nm"
    MAP_PLOT_DATA, azimuths, zeniths, dns, title
  ENDIF ELSE IF keyword_set(surface) THEN BEGIN
    POLAR_SURFACE_PLOT, azimuths, zeniths, dns
  ENDIF
  
  wset, win_image_id
  
  erase
  
  SHOW_SKY_IMAGE, datetime, image_dir
  
  dgratio = GET_D_TO_G_RATIO(datetime, sunshine_file)
  
  print, "DG ratio is " + dgratio
  
  WIDGET_CONTROL, label_dgratio, SET_VALUE=dgratio
  
END


PRO SKRAMVIS_EVENT, EVENT
  print, "Event Detected"
  
  ; Get the info structure from the uvalue of the base widget
  widget_control, event.top, get_uvalue=infoptr
  info = *infoptr
  
  ; Get the uvalue of the widget that caused the event
  widget_control, event.id, get_uvalue=widget
  
  print, widget
  
  help, event, /structure
  
  print, info.win_contour_id
  
  if (STRPOS(widget, "List") ne -1) THEN BEGIN
    info.list_index = event.index
    *infoptr = info
    print, info.list_index
  ENDIF ELSE IF (STRPOS(widget, "Checkbox") ne -1) THEN BEGIN
    info.normalise = event.select
    *infoptr = info
  ENDIF ELSE IF (STRPOS(widget, "Button") ne -1) THEN BEGIN   
    CASE widget OF
      "MapButton": Visualise_Data, info.dirname, info.list_index, normalise=info.normalise, /MAP, win_contour_id=info.win_contour_id, win_image_id=info.win_image_id, label_dgratio=info.label_dgratio, sunshine_file=info.sunshine_file, image_dir=info.image_dir
      "SurfaceButton": Visualise_Data, info.dirname, info.list_index, normalise=info.normalise, /SURFACE, win_contour_id=info.win_contour_id, win_image_id=info.win_image_id, label_dgratio=info.label_dgratio
      "BrowseButton": Set_Browsed_Text, infoptr
    ENDCASE
  ENDIF  
END

PRO SKRAMVIS
  base = widget_base(col=2, title="Sky Radiance Mapper Visualisation", TLB_FRAME_ATTR=1)
  
  controls_base = widget_base(base, row=4)
  
  filename_base = widget_base(controls_base, col=3)
  label_dirname = widget_label(filename_base, value="Directory:")
  text_dirname = widget_text(filename_base, uvalue="FilenameText", xsize=50)
  button_browse = widget_button(filename_base, value="Browse", uvalue="BrowseButton")
  
  parameters_base = widget_base(controls_base, col=3)
  label_wavelengths = widget_label(parameters_base, value="Wavelength:")
  wavelength_list = string([340, 380, 440, 500, 675, 870, 939, 1020])
  list = widget_list(parameters_base, value=wavelength_list, ysize=8, uvalue="List")
  
  checkbox_base = widget_base(parameters_base, /NONEXCLUSIVE)
  checkbox_normalise = widget_button(checkbox_base, value="Normalise", uvalue="NormaliseCheckbox")
  
  button_base = widget_base(controls_base, row=1)
  button_map = widget_button(button_base, value="Show Contour Plot", uvalue="MapButton")
  button_surface = widget_button(button_base, value="Show Surface Plot", uvalue="SurfaceButton")
  
  copyright_base = widget_base(controls_base, row=1)
  label_copyright = widget_label(copyright_base, value="Created by Robin Wilson, University of Southampton, 2009")
  
  draw_base = widget_base(base, row=3)
  
  draw_contour = widget_draw(draw_base, xsize=600, ysize=450)
  
  dgratio_base = widget_base(draw_base, col=2)
  
  label_label_for_dgratio = widget_label(dgratio_base, value="Diffuse:Global ratio = ")
  label_dgratio = widget_label(dgratio_base, value="", /DYNAMIC_RESIZE)
  
  draw_image = widget_draw(draw_base, xsize=600, ysize=450)
  
  ; Set up info structure
  info = {normalise:0,$
          dirname:'',$
          text_dirname:text_dirname,$
          list:list,$
          list_index:'',$
          type:'',$
          wavelength:'',$
          win_contour_id:0,$
          win_image_id:0,$
          label_dgratio:label_dgratio,$
          last_dir_path:"C:\",$
          image_dir:"D:\UserData\Robin Wilson\Sky_animation\",$
          sunshine_file:"D:\UserData\Robin Wilson\Sunshine Sensor\AlteredData.txt"}
  
  widget_control, base, /realize
  
  ; Put window indices into info
  widget_control, draw_contour, get_value=win_contour_id
  widget_control, draw_image, get_value=win_image_id
  
  info.win_contour_id = win_contour_id
  info.win_image_id = win_image_id
 
  infoptr = ptr_new(info)
  
  widget_control, base, set_uvalue=infoptr
  
  wset, info.win_image_id
  erase
  wset, info.win_contour_id
  erase
  
  info.sunshine_file = dialog_pickfile(TITLE="Select Sunshine Sensor data file")
  info.image_dir = dialog_pickfile(TITLE="Select image directory", /directory)
  
  xmanager, 'SKRAMVIS', base, /no_block
END