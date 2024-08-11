*&---------------------------------------------------------------------*
*& Report zupdate_header_eew_data
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zupdate_header_eew_data.

* This sample program shows how one an outbound delivery order (ODO)
* a customer-specific field (Z_ZUSATZ) is filled/changed.
* The program does a locking and reading of the data
* it then changes the EEW field * the program also contains error handling
* It also considers validation errors * based on if errors occurred or not it saves or rejects (ROLLBACK) the changes.
* The program uses the delivery service provider (SP). * The program is meant to be used as a separate program, so not to be used inside a BADI or
* other already running programs (as the setting of the warehouse/save/rollback will destroy a running LUW/transaction)
* Note: The program is only for demo purpose. It is not meant for any * productive usage.

START-OF-SELECTION.


* create service provider for processing delivery and and message box
* the service provider is not used here for a UI (so no attribute handler is used)
  TRY.
      DATA(lo_message_box) = NEW /scdl/cl_sp_message_box( ).
      DATA(lo_sp) = NEW /scdl/cl_sp_prd_out(
        io_message_box       = lo_message_box
        iv_mode              = /scdl/cl_sp=>sc_mode_classic
        iv_doccat            = /scdl/if_dl_doc_c=>sc_doccat_out_prd
      ).
  ENDTRY.


* set warehouse that is used
  /scwm/cl_tm=>set_lgnum( 'QX01' ).

  lo_sp->lock(
    EXPORTING
      inkeys       = VALUE  /scdl/t_sp_k_head( ( docid = '16AB96E3ADA21EEDAA8D127413A9AEF1' ) )
      aspect       = /scdl/if_sp_c=>sc_asp_head
      lockmode     = /scdl/if_sp1_locking=>sc_exclusive_lock
    IMPORTING
      rejected     = DATA(lv_rejected)
      return_codes = DATA(lt_return_codes)
  ).

* check if any error occurred
  IF line_exists( lt_return_codes[ 1 ] ) OR lv_rejected EQ abap_true.
    RETURN.
  ENDIF.

  CLEAR: lv_rejected, lt_return_codes.

* select customer fields EEW for the delivery
  DATA: lt_a_head_eew TYPE /scdl/t_sp_a_head_eew_prd.

  lo_sp->select(
    EXPORTING
      inkeys       = VALUE  /scdl/t_sp_k_head( ( docid = '16AB96E3ADA21EEDAA8D127413A9AEF1' ) )
      aspect       = /scdl/if_sp_c=>sc_asp_head_eew_prd
    IMPORTING
      outrecords   = lt_a_head_eew
      rejected     = lv_rejected
      return_codes = lt_return_codes
  ).

* check if any error occurred
  IF line_exists( lt_return_codes[ 1 ] ) OR lv_rejected EQ abap_true.
    RETURN.
  ENDIF.

  LOOP AT lt_a_head_eew ASSIGNING FIELD-SYMBOL(<ls_a_head_eew>).
* now fill the customer specific field Z_ZUSATZ
    <ls_a_head_eew>-z_zusatz = '5'.
  ENDLOOP.

  CLEAR: lv_rejected, lt_return_codes.

  DATA: lt_a_head_eew_out TYPE /scdl/t_sp_a_head_eew_prd.

  lo_sp->update(
    EXPORTING
      aspect       = /scdl/if_sp_c=>sc_asp_head_eew_prd
      inrecords    = lt_a_head_eew
    IMPORTING
      outrecords   = lt_a_head_eew_out
      rejected     = lv_rejected
      return_codes = lt_return_codes
  ).

* check if any error occurred
  IF line_exists( lt_return_codes[ 1 ] ) OR lv_rejected EQ abap_true.
    RETURN.
  ENDIF.
  CLEAR: lv_rejected, lt_return_codes.
* validate the delivery (also triggers determinations)
* this is an optional step. It is assumed in this example that if validation errors occur
* the delivery should not get saved.
* If also deliveries with validation errors (blocked status) should get saved,
* the error handling has to distinguish between validation errors and other errors
* validation error messages are in the message box and are not returned as REJECTED or RETURN_CODES

  DATA:  lt_a_head  TYPE /scdl/t_sp_a_head.

  lo_sp->execute(
    EXPORTING
      aspect             = /scdl/if_sp_c=>sc_asp_head
      inkeys             = VALUE  /scdl/t_sp_k_head( ( docid = '16AB96E3ADA21EEDAA8D127413A9AEF1' ) )
      inparam            = VALUE /scdl/s_sp_act_action( action_code = /scdl/if_bo_action_c=>sc_validate )
      action             = /scdl/if_sp_c=>sc_act_execute_action
*    relation_inkey     =
*    relation           =
    IMPORTING
      outrecords         = lt_a_head
      rejected           = lv_rejected
      return_codes       = lt_return_codes
  ).
  IF line_exists( lt_return_codes[ 1 ] ) OR lv_rejected EQ abap_true.
    RETURN.
  ENDIF.
  CLEAR: lv_rejected, lt_return_codes.

* get all messages that occurred. Get the always as validation messages * are also of interest
  DATA(lt_messages) = lo_message_box->get_messages( ).
  LOOP AT lt_messages TRANSPORTING NO FIELDS WHERE msgty CA 'EAX'.
    EXIT.
  ENDLOOP.
  IF sy-subrc EQ 0. RETURN. ENDIF.

  LOOP AT lt_messages ASSIGNING FIELD-SYMBOL(<ls_messages>) WHERE consistency_message = abap_true.
    IF <ls_messages>-msgty CA 'EAX'.
      DATA(lv_error) = abap_true.
    ENDIF.
  ENDLOOP..
  IF lv_error EQ abap_true. RETURN. ENDIF.


  CLEAR: lv_rejected, lt_return_codes.
  lo_sp->save( IMPORTING rejected = lv_rejected ).

* check if during save serious errors occurred.
  IF lv_rejected = abap_true.
* if errors occurred then get the messages again
    lt_messages = lo_message_box->get_messages( ).
  ENDIF.
  LOOP AT lt_messages ASSIGNING <ls_messages> WHERE msgty CA 'EAX'.
    EXIT.
  ENDLOOP.
  IF  sy-subrc EQ 0.
    ROLLBACK WORK.
  ELSE.
    COMMIT WORK AND WAIT.
  ENDIF.
  /scwm/cl_tm=>cleanup( ).
