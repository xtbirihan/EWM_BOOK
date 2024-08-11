class ZCL_WRKC_UI_SCAN1 definition
  public
  final
  create public .

public section.

  interfaces /SCWM/IF_EX_WRKC_UI_SCAN_SCR .
  interfaces IF_BADI_INTERFACE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_WRKC_UI_SCAN1 IMPLEMENTATION.


  method /SCWM/IF_EX_WRKC_UI_SCAN_SCR~SET_TAB_NAME.

    ev_text_scanner_badi_3 = text-001. "HU Multi Repack

  endmethod.
ENDCLASS.
