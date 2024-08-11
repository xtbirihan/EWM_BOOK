*&---------------------------------------------------------------------*
*& Report zewm_bin_transfer
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zewm_bin_transfer.

DATA: gv_lgnum          TYPE /scwm/lgnum VALUE 'QX01',
      gv_pmat           TYPE matnr VALUE 'PMPALLET',
      gv_hu_storage_bin TYPE /scwm/de_ui_id VALUE 'WA-PACK-JGC'.

START-OF-SELECTION.

  " set warehouse that is used
  /scwm/cl_tm=>set_lgnum( gv_lgnum ).

  "create object
  DATA(go_create) = NEW /scwm/cl_wm_packing( ).

  "Initialize class with warehouse
  go_create->init( gv_lgnum ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    RETURN.
  ENDIF.

  /scwm/cl_wm_packing=>set_global_fields( gv_lgnum ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    RETURN.
  ENDIF.

  "to initialize WarehouseTask Processing
  CALL FUNCTION '/SCWM/TO_INIT_NEW'
    EXPORTING
      iv_lgnum = gv_lgnum.

  "read existing hu
  BREAK-POINT.
  go_create->get_hu(
    EXPORTING
      iv_huident =  '800000855'             " Handling Unit Identification
    IMPORTING
      et_huitm   = DATA(lt_huitm)    " Material Items in the HU
      es_huhdr   = DATA(ls_huhdr)    " Internal Structure for Processing the HU Header
    EXCEPTIONS
      not_found  = 1
      OTHERS     = 2
  ).

*  "move hu to new bin
  go_create->/scwm/if_pack_bas~move_hu(
    EXPORTING
      iv_hu  = ls_huhdr-guid_hu "Existing Bin
      iv_bin = 'GI-STAGING-02' "New Bin
  ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    RETURN.
  ENDIF.
  go_create->/scwm/if_pack_bas~save(
    EXPORTING
      iv_commit = abap_true
      iv_wait   = abap_true
  ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    RETURN.
  ENDIF.





















  /scwm/cl_tm=>cleanup( ).
