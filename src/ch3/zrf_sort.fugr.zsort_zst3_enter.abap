FUNCTION zsort_zst3_enter.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  CHANGING
*"     REFERENCE(ZSORT) TYPE  ZRF_SORT
*"     REFERENCE(CT_INQ_HU_LOOP) TYPE  /SCWM/TT_RF_INQ_HU_LOOP
*"     REFERENCE(CS_INQ_HU) TYPE  /SCWM/S_RF_INQ_HU
*"----------------------------------------------------------------------

  DATA: ls_inq_hu TYPE /scwm/s_rf_inq_hu_loop.
  BREAK-POINT ID zrf_sort.
*1 validationofuser-input
  READ TABLE ct_inq_hu_loop INTO ls_inq_hu
  INDEX cs_inq_hu-selno.
  IF sy-subrc IS NOT INITIAL.
    message e108(/scwm/rf_en) WITH cs_inq_hu-selno.
  ENDIF.
*2 forwarduser-selectiontoscreen2
  zsort-rfhu = ls_inq_hu-huident.
  /scwm/cl_rf_bll_srvc=>set_screen_param('ZSORT').




ENDFUNCTION.
