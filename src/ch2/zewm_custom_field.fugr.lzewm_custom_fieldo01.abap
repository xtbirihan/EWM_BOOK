*----------------------------------------------------------------------*
***INCLUDE LZEWM_CUSTOM_FIELDO01.
*----------------------------------------------------------------------*
MODULE prdo_screen_pbo OUTPUT.
  /scwm/cl_dlv_ui_badi_mgmt=>pbo_item( iv_transaction = /scwm/if_ex_dlv_ui_screen=>sc_ta_prdo ).
ENDMODULE.
