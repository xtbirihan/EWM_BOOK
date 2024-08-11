*&---------------------------------------------------------------------*
*& Report zewm_snote_delivery_sp
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zewm_snote_delivery_sp.

START-OF-SELECTION.
  DATA: lt_outrecords TYPE /scdl/t_sp_a_head.
  DATA: lt_a_item  TYPE /scdl/t_sp_a_item.

  DATA(lo_message_box) = NEW /scdl/cl_sp_message_box( ).

  "Create a service provider instance to handle outbound delivery orders (here DOCCAT = PDO).
  DATA(lo_sp) = NEW /scdl/cl_sp_prd_out(
*  io_attribute_handler = "The attribute handler is only needed if, for example, fields should be displayed as changeable or not
*  io_message_handler   =
    io_message_box       = lo_message_box "Any messages issued are stored in the message box.
    iv_mode              = /scdl/cl_sp=>sc_mode_classic
    iv_doccat            = /scdl/if_dl_doc_c=>sc_doccat_out_prd
  ).

  "Read the order (the order BO instance is created with all items and data in the background)
  lo_sp->select(
    EXPORTING
      inkeys       = VALUE /scdl/t_sp_k_head( ( docid  = '16AB96E3ADA21EEDA8E261706E9C4EF1' ) )
      aspect       = /scdl/if_sp_c=>sc_asp_head
    IMPORTING
      outrecords   = lt_outrecords
      rejected     = DATA(lv_rejected)
      return_codes = DATA(lt_return_codes)
  ).

  BREAK-POINT.

  "Read the items for the order header.
  "Note that this only returns the items that were read before with a SELECT or QUERY method.

  lo_sp->select_by_relation(
    EXPORTING
      relation     = /scdl/if_sp_c=>sc_rel_head_to_item
      inrecords    = VALUE /scdl/t_sp_k_head( ( docid  = '16AB96E3ADA21EEDA8E261706E9C4EF1' ) )
      aspect       = /scdl/if_sp_c=>sc_asp_head
    IMPORTING
      outrecords   = lt_a_item
      rejected     = lv_rejected
      return_codes = lt_return_codes
  ).

* get incoterms
  "Read detail data of an object (here Incoterms of an order header).
  DATA: lt_a_head_incoterms  TYPE /scdl/t_sp_a_head_incoterms .

  lo_sp->select(
    EXPORTING
      inkeys       = VALUE /scdl/t_sp_k_head( ( docid  = '16AB96E3ADA21EEDA8E261706E9C4EF1' ) )
      aspect       = /scdl/if_sp_c=>sc_asp_head_incoterms
    IMPORTING
      outrecords   = lt_a_head_incoterms
      rejected     = lv_rejected
      return_codes = lt_return_codes
  ).

  "This example shows how the (complete) order is locked
  lo_sp->lock(
    EXPORTING
      inkeys       = VALUE /scdl/t_sp_k_head( ( docid  = '16AB96E3ADA21EEDA8E261706E9C4EF1' ) )
      aspect       = /scdl/if_sp_c=>sc_asp_head
      lockmode     = /scdl/if_sp1_locking=>sc_exclusive_lock
    IMPORTING
      rejected     = lv_rejected
      return_codes = lt_return_codes
  ).

  "Here an additional party/location is added on header level. As a header can contain multiple parties/locations (1:n), this uses a relation.
*  lo_sp->insert(
*    EXPORTING
*      inrecords          = lt_a_head_partyloc
*      aspect             = /scdl/if_sp_c=>sc_asp_head_partyloc
*      relation           = /scdl/if_sp_c=>sc_rel_head_to_partyloc
*      relation_inkey     = ls_sp_k_head
*    IMPORTING
*      outrecords         = lt_a_head_partyloc_out
*      relation_outrecord = ls_a_head_out
*      rejected           = lv_rejected_tmp
*      return_codes       = lt_return_codes
*  ).

  "Here a 1:n aspect of the header is updated.,
  DATA: lt_a_head_incoterms_out  TYPE /scdl/t_sp_a_head_incoterms.
  lo_sp->update(
    EXPORTING
      aspect       = /scdl/if_sp_c=>sc_asp_head_incoterms
      inrecords    =  lt_a_head_incoterms
    IMPORTING
      outrecords   = lt_a_head_incoterms_out
      rejected     = lv_rejected
      return_codes = lt_return_codes
  ).

  "Here an action is executed on header level.
  "In this example, the generic action “execute action” is used to execute the BOPF action “determine”
  DATA: ls_action TYPE /scdl/s_sp_act_action,
        lt_a_head TYPE /scdl/t_sp_a_head.

  ls_action-action_code = /scdl/if_bo_action_c=>sc_determine.

  lo_sp->execute(
    EXPORTING
      aspect             = /scdl/if_sp_c=>sc_asp_head
      inkeys             = VALUE /scdl/t_sp_k_head( ( docid  = '16AB96E3ADA21EEDA8E261706E9C4EF1' ) )
      inparam            = ls_action
      action             = /scdl/if_sp_c=>sc_act_execute_action
    IMPORTING
      outrecords         = lt_a_head
      rejected           = lv_rejected
      return_codes       = lt_return_codes
  ).



  "Get any detailed messages issued during the service provider calls.
  "In the example, this is only done if a major failure occurred
  "(usually RETURN_CODES should also be evaluated)

* add messages
  IF lv_rejected = abap_true.
    DATA(lt_messages) = lo_message_box->get_messages( ).
  ENDIF.
