;;;Download, calibrate and make base difference STEREO data
event = FILE_DIRNAME(ROUTINE_FILEPATH())

step = 1  ;;; get STEREO data
;1. Get stereo data
IF step EQ 1 then BEGIN
    FILE_MKDIR, event + '/STEREO/orig/'

 
    secchi_vso_ingest, '2012-04-05 20:00', '2012-04-05 23:30', SPACECRAFT='Ahead', $
    TELESCOPE='COR2', OUT_DIR= event + '/STEREO/orig/'

ENDIF

step = 2 ;;; calibrate STEREO data

;2. Calibrate data 
IF step EQ 2 then BEGIN
  
  path_data= event + '/STEREO/orig/'
  FILE_MKDIR, event + '/STEREO/cal/'
  path_cal=event + '/STEREO/cal/'
 
  files = findfile(path_data +'*.fts' ) ;;;name of files in the folder
  N=n_elements(files) ;;;number of files

  
   ;;;FOR COR !!!!
   SECCHI_PREP, files, headers, data, /rotate_on, /write_fts, savepath = path_cal, /NOCALFAC, /CALIMG_OFF, /UPDATE_HDR_OFF, /EXPTIME_OFF 
   
ENDIF        

step = 3 ;;; make base difference data                                                                    
    
    
;3. Make base difference images 
IF step EQ 3 then BEGIN
           

    path_data= event + '/STEREO/cal/'  ;;; where calibrated data are saved
    FILE_MKDIR, event + '/STEREO/base_diff_sav/'
    path_save=event + '/STEREO/base_diff_sav/' ;;; where to save base difference data


    files = file_search(path_data +'*.fits' ) ;;;name of files in the folder
    N=n_elements(files)                   ;;;number of files
    

    fits2map, files, maps    ;;;to read in idl and create maps (actual image data)
    
  
    time_start=maps[0].time  ;;;base image (first image in the array, but it can be any needed image)
   
    hh_start=STRMID(time_start, 12, 2)  ;;;to create time (hour) in the name of file of new image 
    mm_start=STRMID(time_start, 15, 2)  ;;;to create time (min) in the name of file of new image 
    ss_start=STRMID(time_start, 18, 2)  ;;;to create time (sec) in the name of file of new image     

   

    ;;;create base difference images in a cycle
     for it=1,N-1 do begin
     ;for it=2,N-1 do begin
      print, it
      map_rot=drot_map(maps[it],REF_MAP=maps[0], /KEEP_LIMB)  ;;;differential rotation to base image,
     
      dmap=diff_map(map_rot,maps[0])  ;;;substract current image (that was differentially rotated) from base image

      time_cur=maps[it].time
      hh=STRMID(time_cur, 12, 2)   ;;;to create time (hour) in the name of file of new image 
      mm=STRMID(time_cur, 15, 2)   ;;;to create time (min) in the name of file of new image 
      ss=STRMID(time_cur, 18, 2)   ;;;to create time (sec) in the name of file of new image 


      fname=''

      fname_save=fname+'BDif_'+hh+mm+ss+'_'+hh_start+mm_start+ss_start+'.sav'
      
      SAVE, dmap, FILENAME = path_save+fname_save
    endfor

ENDIF

step = 3.1 ;;; make fits
IF step EQ 3.1 then BEGIN
  path_data=event + '/STEREO/base_diff_sav/'
  FILE_MKDIR, event + '/STEREO/base_diff_fits/'
  file_save=event + '/STEREO/base_diff_fits/'

  files = file_search(path_data +'*.sav' )

  N=n_elements(files)

  for it=0,N-1 do begin
    print,it
    restore,files[it]

    filename = STRMID(files[it],50 , 50)

    map=DMAP
    map.rtime=map.time
    map2fits,map,file_save+filename+'.fits'
  endfor

endif

step = 4 ;;; make log base ratio data
;4. Make log base ratio images
IF step EQ 4 then BEGIN

  path_data= event + '/STEREO/cal/'  ;;; where calibrated data are saved
  FILE_MKDIR, event + '/STEREO/LBR_sav/'
  path_save=event + '/STEREO/LBR_sav/' ;;; where to save base difference data

  files = findfile(path_data +'*.fits' ) ;;;name of files in the folder
  N=n_elements(files)                   ;;;number of files

  fits2map, files, maps    ;;;to read in idl and create maps (actual image data)
  
  time_start=maps[0].time  ;;;base image (first image in the array, but it can be any needed image)
  ;time_start=maps[1].time  ;;;base image (first image in the array, but it can be any needed image)

  hh_start=STRMID(time_start, 12, 2)  ;;;to create time (hour) in the name of file of new image
  mm_start=STRMID(time_start, 15, 2)  ;;;to create time (min) in the name of file of new image
  ss_start=STRMID(time_start, 18, 2)  ;;;to create time (sec) in the name of file of new image

  ;;;create base difference images in a cycle
  for it=1,N-1 do begin
    ;for it=2,N-1 do begin
    print, it
    map_rot=drot_map(maps[it],REF_MAP=maps[0], /KEEP_LIMB)  ;;;differential rotation to base image,
    dmap=diff_map(map_rot,maps[0],/RATIO)  ;;;substract current image (that was differentially rotated) from base image
     
    data=dmap.data
    ind_sm=where(data le 0.0001)
    data(ind_sm)=0.0001
    data_log=alog10(data)
    dmap.data=data_log
    
    time_cur=maps[it].time
    hh=STRMID(time_cur, 12, 2)   ;;;to create time (hour) in the name of file of new image
    mm=STRMID(time_cur, 15, 2)   ;;;to create time (min) in the name of file of new image
    ss=STRMID(time_cur, 18, 2)   ;;;to create time (sec) in the name of file of new image

   fname=''

      fname_save=fname+'LBR_'+hh+mm+ss+'_'+hh_start+mm_start+ss_start+'.sav'

    SAVE, dmap, FILENAME = path_save+fname_save
  endfor

ENDIF

step = 4.1 ;;; make log base ratio data
IF step EQ 4.1 then BEGIN
  path_data=event + '/STEREO/LBR_sav/'
  FILE_MKDIR, event + '/STEREO/LBR_fits/'
  file_save=event + '/STEREO/LBR_fits/'

  files = file_search(path_data +'*.sav' )

  N=n_elements(files)

  for it=0,N-1 do begin
    print,it
    restore,files[it]

    filename = STRMID(files[it],50 , 50)

    map=DMAP
    map.rtime=map.time
    map2fits,map,file_save+filename+'.fits'
  endfor

endif
                                                                               ;  
                    
end