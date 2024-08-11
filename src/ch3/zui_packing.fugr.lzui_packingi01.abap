*----------------------------------------------------------------------*
***INCLUDE LZUI_PACKINGI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  SCAN_DEST_HU_999  INPUT
*&---------------------------------------------------------------------*
MODULE scan_dest_hu_999 INPUT.
* user scanned a destination HU-> readHU
  CLEAR: gs_dest_hu.
  IF /scwm/s_pack_view_scanner-dest_hu_prop_ui IS NOT INITIAL.

    /scwm/s_pack_view_scanner-dest_hu = /scwm/s_pack_view_scanner-dest_hu_prop_ui.
    go_model->get_hu(
      EXPORTING
        iv_huident = /scwm/s_pack_view_scanner-dest_hu " Handling Unit Identification
      IMPORTING
        es_huhdr   = gs_dest_hu   " Internal Structure for Processing the HU Header
      EXCEPTIONS
        not_found  = 99
    ).
    IF sy-subrc <> 0.
      CLEAR /scwm/s_pack_view_scanner-dest_hu_prop_ui.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SCAN_SOURCE_999  INPUT
*&---------------------------------------------------------------------*
MODULE scan_source_999 INPUT.
*1 user scanned a source HU -> read HU
  CLEAR: gs_source_hu.

  IF /scwm/s_pack_view_scanner-source_hu_ui IS NOT INITIAL.

    /scwm/s_pack_view_scanner-source_hu = /scwm/s_pack_view_scanner-source_hu_ui.

    go_model->get_hu(
      EXPORTING
        iv_huident =  /scwm/s_pack_view_scanner-source_hu " Handling Unit Identification
      IMPORTING
        es_huhdr   = gs_source_hu   " Internal Structure for Processing the HU Header
      EXCEPTIONS
        not_found  = 99
    ).
    IF sy-subrc <> 0.
      "Scan error -> user must repeat the scan
      CLEAR /scwm/s_pack_view_scanner-source_hu_ui.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDIF.

  "99 Repack the source-hu into the target-HU
  IF gs_source_hu IS NOT INITIAL AND
     gs_dest_hu IS NOT INITIAL.

    go_model->pack_hu(
      EXPORTING
        iv_source_hu = gs_source_hu-guid_hu " Unique Internal Identification of a Handling Unit
        iv_dest_hu   = gs_dest_hu-guid_hu   " Unique Internal Identification of a Handling Unit
      EXCEPTIONS
        error        = 1            " Error, see log
    ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    /scwm/cl_pack=>go_log->init( ).

    "Clear input field for the next source-hu
    CLEAR: gs_source_hu,
    /scwm/s_pack_view_scanner-source_hu_ui.
  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_999  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_999 INPUT.
  "User wants to scan a new target hu, clear the field
  IF sy-ucomm EQ 'F8'.
    CLEAR /scwm/s_pack_view_scanner-dest_hu_prop_ui.
    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
      EXCEPTIONS
        OTHERS = 99.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDIF.
ENDMODULE.
