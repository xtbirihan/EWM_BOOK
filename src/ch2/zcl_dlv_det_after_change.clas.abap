CLASS zcl_dlv_det_after_change DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES /scwm/if_ex_dlv_det_after_chan .
    INTERFACES if_badi_interface .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: mt_det_relevant_keys TYPE /scwm/dlv_detval_key_tab.
ENDCLASS.



CLASS ZCL_DLV_DET_AFTER_CHANGE IMPLEMENTATION.


  METHOD /scwm/if_ex_dlv_det_after_chan~check_header.
  ENDMETHOD.


  METHOD /scwm/if_ex_dlv_det_after_chan~check_item.
    DATA: lo_item     TYPE REF TO /scdl/cl_dl_item_prd,
          lo_item_old TYPE REF TO /scdl/cl_dl_item_prd.
    IF sy-uname NE 'T.BIRIHAN'.
      RETURN.
    ENDIF.

    "* ensure that the coding is only processed for DOCCAT=PDO.
    "* as an (better) alternative also a DOCCAT filter for the BADI can be used. (BADI configuration)
    IF iv_doccat <> /scdl/if_dl_doc_c=>sc_doccat_out_prd.
      RETURN.
    ENDIF.
    "* clear relevant keys.
    CLEAR: mt_det_relevant_keys.

    "*get BOM
    DATA(lo_bom) = /scdl/cl_bo_management=>get_instance( ).

    "* define states for reading of objects
*    DATA(lv_laststate) = /scdl/if_dl_object_c=>sc_object_state_determ.
    DATA(lv_laststate2) = /scdl/if_dl_object_c=>sc_object_state_db.


    "* process the items
    LOOP AT it_keys ASSIGNING FIELD-SYMBOL(<fs_keys>).
      "* get BO
      DATA(lo_bo) = lo_bom->get_bo_by_id( iv_docid = <fs_keys>-docid ).
      IF lo_bo IS NOT BOUND.
        CONTINUE.
      ENDIF.

      "* get current header
      DATA(lo_header) = lo_bo->get_header( ).

      "* get header before the last determination (old state)
      DATA(lo_header_old) = lo_bo->get_header( iv_objectstate = /scdl/if_dl_object_c=>sc_object_state_determ ).
      IF   lo_header_old IS NOT BOUND.
        lo_header_old = lo_bo->get_header( iv_objectstate = /scdl/if_dl_object_c=>sc_object_state_db ).
      ENDIF.

      "* get old and current incoterms
      DATA(ls_incoterms) = lo_header->get_incoterms( ).
      DATA(ls_incoterms_old) = lo_header_old->get_incoterms( ).

      "* get current item state
      lo_item ?= lo_bo->get_item( iv_itemid = <fs_keys>-itemid ).

      "* get item before the last determination (old state)
      lo_item_old ?= lo_bo->get_item(
                       iv_itemid      = <fs_keys>-itemid
                       iv_objectstate = /scdl/if_dl_object_c=>sc_object_state_determ
                     ).
      IF lo_item_old IS NOT BOUND.
        lo_item_old ?= lo_bo->get_item(
                          iv_itemid      = <fs_keys>-itemid
                          iv_objectstate = /scdl/if_dl_object_c=>sc_object_state_db
                        ).
      ENDIF.

      "* get old and current sapext for outbound
      lo_item->get_sapext( IMPORTING es_sapext_o = DATA(ls_sapext_o) ).
      IF lo_item_old IS BOUND.
        lo_item_old->get_sapext( IMPORTING es_sapext_o = DATA(ls_sapext_o_old) ).
      ENDIF.

      "* if incoterm or the product changed, then trigger that the determination execute method is called.
      IF ls_incoterms-inco1 <> ls_incoterms_old-inco1 OR
         ls_sapext_o-/scwm/door <> ls_sapext_o_old-/scwm/door.
        "* append to relevant keys. Note that this parameter is used for all BADI implementations.
        "* therefore you must not remove entries, but only add entries
        COLLECT <fs_keys> INTO ct_relevant_keys.

        "* append relevant keys. This parameter is only for this BADI instance, therefore it indicates
        "* which keys are relevant for exactely this BADI (and is also cleared at the beginning)
        COLLECT <fs_keys> INTO mt_det_relevant_keys.
      ENDIF.

      CLEAR: ls_incoterms, ls_incoterms_old, ls_sapext_o, ls_sapext_o_old.
    ENDLOOP.
  ENDMETHOD.


  METHOD /scwm/if_ex_dlv_det_after_chan~execute_header.
  ENDMETHOD.


  METHOD /scwm/if_ex_dlv_det_after_chan~execute_item.
    DATA: lo_item_prd TYPE REF TO /scdl/cl_dl_item_prd.
    IF sy-uname NE 'T.BIRIHAN'.
      RETURN.
    ENDIF.
    "* get BOM
    DATA(lo_bom) = /scdl/cl_bo_management=>get_instance( ).

    "* process the items
    LOOP AT it_relevant_keys  ASSIGNING FIELD-SYMBOL(<fs_keys>).
      "* the reading of mt_det_relevant_keys which was set in the CHECK_ITEM method
      "* ensures that this method is only processed for the relevant keys * This is necessary in case of multiple BADI implementations, as it could happen that
      "* an other implementation added more keys to IT_RELEVANT_KEYS
      IF NOT line_Exists( mt_det_relevant_keys[ docid = <fs_keys>-docid
                                                itemid = <fs_keys>-itemid ] ).
        CONTINUE.
      ENDIF.

      "* get BO
      DATA(lo_bo) = lo_bom->get_bo_by_id( iv_docid =  <fs_keys>-docid ).
      IF lo_bo IS NOT BOUND.
        CONTINUE.
      ENDIF.

      "* get current customer extension for outbound processing deliveries
      "* keep in mind that here lo_item_prd is of type /scdl/cl_dl_item_prd
      lo_item_prd ?= lo_bo->get_item( iv_itemid = <fs_keys>-itemid ).
      DATA(ls_eew) = lo_item_prd->get_eew( ).
      "* now customer specific fields could be updated in LS_EEW
      ls_eew-zz_myown_field = 'TEST'.
    ENDLOOP.


  ENDMETHOD.
ENDCLASS.
