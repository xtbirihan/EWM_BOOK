*&---------------------------------------------------------------------*
*& Report zupdate_header_with_manager
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zupdate_header_with_manager.


START-OF-SELECTION.

* set warehouse that is used
  /scwm/cl_tm=>set_lgnum( 'QX01' ).

  BREAK-POINT.
  DATA: lv_docid  TYPE /scdl/dl_docid  VALUE '16AB96E3ADA21EEDAA8D127413A9AEF1'.
  DATA: lo_header_prd TYPE REF TO /scdl/cl_dl_header_prd.

  "get business object manager(BOM)
  DATA(lo_bom) = /scdl/cl_bo_management=>get_instance( ).

  "query, BO won't be bounded without reading the doc id.
  DATA(lo_dl_query) = NEW /scdl/cl_dl_query( iv_doccat =  /scdl/if_dl_doc_c=>sc_doccat_out_prd ).
  lo_dl_query->add_docid( iv_docid = lv_docid ).

  lo_bom->query(
    EXPORTING
      io_query            = lo_dl_query
      iv_lock_mode        = /scdl/if_dl_object_c=>sc_lock_exclusive
      iv_data_source      = /scdl/if_dl_query_c=>sc_source_unknown
    IMPORTING
      eo_message          =  DATA(lo_message)
  ).
  DATA(lt_messages) =  lo_message->get_messages( ).
  LOOP AT lt_messages ASSIGNING FIELD-SYMBOL(<fs_messages>) WHERE msgty CA 'EAX'.
    EXIT.
  ENDLOOP.
  IF sy-subrc EQ 0.
    RETURN.
  ENDIF.

  "get BO
  DATA(lo_bo) = lo_bom->get_bo_by_id( iv_docid = lv_docid ).
  IF lo_bo IS NOT BOUND.
    RETURN.
  ENDIF.

  "get header from bo
  lo_header_prd ?= lo_bo->get_header(
    EXPORTING
      iv_objectstate = /scdl/if_dl_object_c=>sc_object_state_curr
      iv_docid       = lv_docid ).

  IF  lo_header_prd IS NOT BOUND.
    RETURN.
  ENDIF.

  "get custom fields
  DATA(ls_eew) = lo_header_prd->get_eew( ).
  ls_eew-z_zusatz = '3'.

  "set custom fields
  lo_header_prd->set_eew( is_eew = ls_eew ).
  lo_bom->save( ).

  COMMIT WORK AND WAIT.

  /scwm/cl_tm=>cleanup( ).
