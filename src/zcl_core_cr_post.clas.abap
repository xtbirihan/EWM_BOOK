class ZCL_CORE_CR_POST definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /SCWM/IF_EX_CORE_CR_POST .
protected section.
private section.
ENDCLASS.



CLASS ZCL_CORE_CR_POST IMPLEMENTATION.


  method /SCWM/IF_EX_CORE_CR_POST~POST.

*    DATA: lv_uname TYPE sy-uname VALUE 'ZZZ'.
*    BREAK lv_uname.

  endmethod.
ENDCLASS.
