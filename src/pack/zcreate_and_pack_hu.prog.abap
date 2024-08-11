*&---------------------------------------------------------------------*
*& Report zcreate_and_pack_hu
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zcreate_and_pack_hu.

START-OF-SELECTION.
  DATA: gv_lgnum          TYPE /scwm/lgnum VALUE 'QX01',
        gv_pmat           TYPE matnr VALUE 'PMPALLET',
        gv_hu_storage_bin TYPE /scwm/de_ui_id VALUE 'WA-PACK-JGC'.

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

  "initialize Warehouse Task Processing
  CALL FUNCTION '/SCWM/TO_INIT_NEW'
    EXPORTING
      iv_lgnum = gv_lgnum.

  BREAK-POINT.
  DATA(gv_matid) = NEW /scwm/cl_ui_stock_fields( )->get_matid_by_no( iv_matnr = gv_pmat ).

  "create an empty HU
  DATA(gs_huhdr) = go_create->/scwm/if_pack_bas~create_hu(
     EXPORTING
       iv_pmat      = gv_matid "Packaging material
**       iv_huident   = ''
       i_location   = gv_hu_storage_bin

   ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    RETURN.
  ENDIF.

  " save an empty HU
  go_create->/scwm/if_pack_bas~save(
  EXPORTING
    iv_commit = 'X'
    iv_wait   = 'X'
  EXCEPTIONS
    error     = 1
    OTHERS    = 2
  ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    RETURN.
  ENDIF.
  "

  "pack handling unit
  go_create->/scwm/if_pack_bas~pack_hu(
    EXPORTING
      iv_source_hu = gs_huhdr-guid_hu
      iv_dest_hu   = gs_huhdr-guid_hu ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    RETURN.
  ENDIF.

  go_create->/scwm/if_pack_bas~save(
  EXPORTING
    iv_commit = 'X'
    iv_wait   = 'X'
  EXCEPTIONS
    error     = 1
    OTHERS    = 2
  ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    RETURN.
  ENDIF.

  /scwm/cl_tm=>cleanup( ).
