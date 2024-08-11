FUNCTION zsort_zst1_init.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  CHANGING
*"     REFERENCE(ZSORT) TYPE  ZRF_SORT
*"----------------------------------------------------------------------

  DATA: ls_pack_controle TYPE /scwm/s_pack_controle,
        ls_rsrc          TYPE /scwm/rsrc,
        ls_sort          TYPE zrf_sort.

  BREAK-POINT ID zrf_sort.

  CLEAR zsort.

  CALL FUNCTION '/SCWM/RSRC_RESOURCE_MEMORY'
    EXPORTING
      iv_uname = sy-uname
    CHANGING
      cs_rsrc  = ls_rsrc.

  zsort-lgnum = ls_rsrc-lgnum.

  "init packing & transaction manager

  /scwm/cl_tm=>set_lgnum( iv_lgnum = zsort-lgnum ).

  IF go_pack IS NOT BOUND.
    /scwm/cl_wm_packing=>get_instance(
      IMPORTING
        eo_instance = go_pack ).
  ENDIF.

  ls_pack_controle-cdstgrp_mat = abap_true."takeovercons.group
  ls_pack_controle-chkpack_dstgrp = '2'."Checkwhilerepackproducts
  ls_pack_controle-processor_det = abap_true.

  go_pack->init(
    EXPORTING
      iv_lgnum               = zsort-lgnum
      is_pack_controle       = ls_pack_controle
    EXCEPTIONS
      error                  = 1
  ).
  IF sy-subrc <> 0.
    /scwm/cl_pack_view=>msg_error( ).
  ENDIF.
  " init stock- ui
  IF go_stock IS NOT BOUND.
    go_stock = NEW #( ).
  ENDIF.
ENDFUNCTION.
