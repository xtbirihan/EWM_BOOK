CLASS zcl_dlv_val_validate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES /scwm/if_ex_dlv_val_validate .
    INTERFACES if_badi_interface .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: mt_val_relevant_keys TYPE /scwm/dlv_detval_key_tab.
    DATA: mv_val_check_executed TYPE boole_d.
ENDCLASS.



CLASS ZCL_DLV_VAL_VALIDATE IMPLEMENTATION.


  METHOD /scwm/if_ex_dlv_val_validate~check_header.
  ENDMETHOD.


  METHOD /scwm/if_ex_dlv_val_validate~check_item.
    DATA: lo_item     TYPE REF TO /scdl/cl_dl_item,
          lo_item_old TYPE REF TO /scdl/cl_dl_item.

    IF sy-uname NE 'T.BIRIHAN'.
      RETURN.
    ENDIF.

    "* clear relevant keys.
    CLEAR: mt_val_relevant_keys.
    "* set that the check_item was executed. This is to differentiate in the EXECUTE_ITEM whether
    "* the validation was called due to a change or if e.g. "check" button was used and all validation
    "* should be executed

    mv_val_check_executed = abap_true.

    "* get BOM
    DATA(lo_bom) = /scdl/cl_bo_management=>get_instance( ).

    "* define states for reading of objects
*    DATA(lv_laststate) = /scdl/if_dl_object_c=>sc_object_state_valid.
*    DATA(lv_laststate2) = /scdl/if_dl_object_c=>sc_object_state_db.

    "* process the items
    LOOP AT it_keys ASSIGNING FIELD-SYMBOL(<fs_keys>).
      "* get BO
      DATA(lo_bo) = lo_bom->get_bo_by_id( iv_docid = <fs_keys>-docid ).
      IF lo_bo IS NOT BOUND. CONTINUE. ENDIF.

      "* get current header
      DATA(lo_header) = lo_bo->get_header( ).

      "* get header before the last determination (old state)

      DATA(lo_header_old) = lo_bo->get_header( iv_objectstate = /scdl/if_dl_object_c=>sc_object_state_valid ).
      IF lo_header_old IS NOT  BOUND.
        lo_header_old = lo_bo->get_header( iv_objectstate = /scdl/if_dl_object_c=>sc_object_state_db ).
      ENDIF.

      "* get current item state
      lo_item ?= lo_bo->get_item( iv_itemid = <fs_keys>-itemid ).

      "* * get item before the last determination (old state)
      lo_item_old = lo_bo->get_item(
                      iv_itemid      = <fs_keys>-itemid
                      iv_objectstate = /scdl/if_dl_object_c=>sc_object_state_valid ).
      IF lo_item_old IS NOT BOUND.
        lo_item_old = lo_bo->get_item(
                        iv_itemid      = <fs_keys>-itemid
                        iv_objectstate = /scdl/if_dl_object_c=>sc_object_state_db ).
      ENDIF.

      "* get old and current product data and quantity
      DATA(ls_qty) = lo_item->get_qty( ).
      DATA(ls_product) = lo_item->get_product( ).

      IF lo_item_old IS BOUND.
        DATA(ls_qty_old) = lo_item_old->get_qty( ).
        DATA(ls_product_old) = lo_item_old->get_product( ).
      ENDIF.

      "* if quantity, UOM or product changed, then trigger that the validation execute method is called.
      IF ls_qty-qty <> ls_qty_old-qty OR
         ls_qty-uom <> ls_qty_old-uom OR
         ls_product-productid <> ls_product_old-productid.
        "* append to relevant keys. Note that this parameter is used for all BADI implementations.
        "* therefore you must not remove entries, but only add entries
        COLLECT <fs_keys> INTO ct_relevant_keys.

        "* append relevant keys. This parameter is only for this BADI instance, therefore it indicates
        "* which keys are relevant for exactely this BADI (and is also cleared at the beginning)
        COLLECT <fs_keys> INTO mt_val_relevant_keys.
      ENDIF.

      CLEAR: ls_qty,ls_qty_old, ls_product, ls_product_old.
    ENDLOOP.

  ENDMETHOD.


  METHOD /scwm/if_ex_dlv_val_validate~execute_header.
  ENDMETHOD.


  METHOD /scwm/if_ex_dlv_val_validate~execute_item.

    DATA: lo_item     TYPE REF TO /scdl/cl_dl_item,
          lv_dummymsg TYPE bapi_msg.

    IF sy-uname NE 'T.BIRIHAN'.
      RETURN.
    ENDIF.

    "* get BOM
    DATA(lo_bom) = /scdl/cl_bo_management=>get_instance( ).

    "* process the items
    LOOP AT it_relevant_keys ASSIGNING FIELD-SYMBOL(<fs_keys>).
      "* if the CHECK_ITEM was called (and mv_val_check_executed is set)
      "* differentiate for which items a change exists. Otherwise check all items
      IF mv_val_check_executed = abap_true.
        "* the reading of mt_det_relevant_keys which was set in the CHECK_ITEM method
        "* ensures that this method is only processed for the relevant keys
        "* This is necessary in case of multiple BADI implementations, as it could happen that
        "* an other implementation added more keys to IT_RELEVANT_KEYS
        IF NOT line_exists( mt_val_relevant_keys[ docid = <fs_keys>-docid
                                              itemid = <fs_keys>-itemid ] ).
          CONTINUE.
        ENDIF.
      ENDIF.
      "* get BO
      DATA(lo_bo) = lo_bom->get_bo_by_id( iv_docid =  <fs_keys>-docid ).
      IF lo_bo IS NOT BOUND. CONTINUE. ENDIF.
      "* get current product and quantity information

      lo_item ?= lo_bo->get_item(  iv_itemid = <fs_keys>-itemid ).
      DATA(ls_qty) = lo_item->get_qty( ).
      DATA(ls_product) = lo_item->get_product( ).
      DATA(lv_qty_is_allowed) = abap_false.

      "* now a customer specific function could be called which
      "* uses the quantity and product information to check whether the
      "* quantity is allowed for the product

*lv_qty_is_allowed = call_my_function( ls_qty ls_product ).

      "* if change is not allowed return a message so that delivery item gets blocked
      IF lv_qty_is_allowed = abap_false AND sy-datum EQ '20230216'.
        MESSAGE ID '/SCWM/DELIVERY' TYPE /scwm/cl_dm_message_no=>sc_msgty_error
                NUMBER '100' WITH 'Quantity ' ls_qty-qty ' not allowed for product '
                ls_product-productno INTO lv_dummymsg.

        DATA(ls_symsg) = /scwm/cl_dm_message_no=>get_symsg_fields( ).
        APPEND VALUE  /scwm/dlv_detval_msg_str( docid = <fs_keys>-docid
                                                itemid = <fs_keys>-itemid
                                                msg = ls_symsg
        ) TO ct_messages.
      ENDIF.

    ENDLOOP.

    "clear the attribute so that it does not influence the next call
    CLEAR mv_val_check_executed.
  ENDMETHOD.
ENDCLASS.
