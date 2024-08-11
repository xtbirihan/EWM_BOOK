*&---------------------------------------------------------------------*
*& Report zewm_test_repack_stock
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zewm_test_repack_stock.

DATA: ls_wrkc  TYPE /scwm/tworkst,
      lv_matnr TYPE /scwm/de_matnr.

PARAMETERS:
  p_lgnum  TYPE /scwm/lgnum MEMORY ID /scwm/lgn OBLIGATORY,
  p_src_hu TYPE /scwm/huident OBLIGATORY,
  p_pkgmat TYPE /scmb/mdl_matnr OBLIGATORY,
  p_wrkc   TYPE /scwm/de_workstation OBLIGATORY.


START-OF-SELECTION.

  /scwm/cl_Tm=>cleanup( iv_lgnum = p_lgnum ).

* Get dummy instance to use the method of the class
  /scwm/cl_wm_packing=>get_instance(
    IMPORTING
      eo_instance = DATA(lo_packing) ).

  lo_packing->init( p_lgnum ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    RETURN.
  ENDIF.

* Read the work center attributes
  CALL FUNCTION '/SCWM/TWORKST_READ_SINGLE'
    EXPORTING
      iv_lgnum       = p_lgnum
      iv_workstation = p_wrkc
    IMPORTING
      es_workst      = ls_wrkc
    EXCEPTIONS
      error          = 1
      not_found      = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    RETURN.
  ENDIF.

* Determine MATID of packaging material
  lv_matnr = p_pkgmat.
  DATA(lv_matid) = NEW /scwm/cl_ui_stock_fields( )->get_matid_by_no(  iv_matnr = lv_matnr ).

* Create a new HU generating a HUIDENT (e.g., SSCC number)
  DATA(ls_huhdr) = lo_packing->/scwm/if_pack_bas~create_hu(
    EXPORTING
      iv_pmat      = lv_matid
      i_location   = ls_wrkc-lgpla
  ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    "error handling
    ROLLBACK WORK.
    /scwm/cl_tm=>cleanup( ).
    RETURN.
  ENDIF.

* Save new HU in Database
  lo_packing->/scwm/if_pack_bas~save(
    EXPORTING
      iv_commit = abap_true
      iv_wait   = abap_true
    EXCEPTIONS
      error     = 1
  ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    "error handling
    ROLLBACK WORK.
    /scwm/cl_tm=>cleanup( ).
    RETURN.
  ENDIF.


* Read source HU
  lo_packing->get_hu(
    EXPORTING
      iv_huident = p_src_hu
    IMPORTING
      et_huitm   = DATA(lt_huitm)
      es_huhdr   = DATA(ls_src_hu)
    EXCEPTIONS
      not_found  = 1
  ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    RETURN.
  ENDIF.

* Repack Stock from source HU into newly created HU
  lo_packing->empty_hu(
    EXPORTING
      iv_hu         = ls_src_hu-guid_hu
      iv_dest_hu    = ls_huhdr-guid_hu
    EXCEPTIONS
      error         = 1
  ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    "error handling
    ROLLBACK WORK.
    /scwm/cl_tm=>cleanup( ).
    RETURN.
  ENDIF.

* Save Results
  lo_packing->/scwm/if_pack_bas~save(
    EXPORTING
      iv_commit = abap_True
      iv_wait   = abap_true
    EXCEPTIONS
      error     = 1
  ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

    "error handling
    ROLLBACK WORK.
    /scwm/cl_tm=>cleanup( ).
    RETURN.
  ENDIF.
  /scwm/cl_tm=>cleanup( ).
