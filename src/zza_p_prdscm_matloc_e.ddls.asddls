@AbapCatalog.sqlViewAppendName: 'ZZA_PMATLOC_V'
@EndUserText.label: 'APO Matdoc Enhacement'
extend view P_Prdscm_Matloc with ZZA_PMATLOC_E
{

  marc.zzindenttab01 as Zzindenttab01,
  marc.zzindenttab02 as Zzindenttab02,
  marc.zzindenttab03 as Zzindenttab03,
  marc.zzindenttab04 as Zzindenttab04,
  marc.zzindenttab05 as Zzindenttab05

}
