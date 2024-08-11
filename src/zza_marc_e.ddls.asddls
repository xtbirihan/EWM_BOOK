@AbapCatalog.sqlViewAppendName: 'ZZA_MARC_V'
@EndUserText.label: 'Extension View For NSDM_V_MARC'
extend view nsdm_e_marc with ZZA_MARC_E
{
      t.zzindenttab01 as Zzindenttab01,
      t.zzindenttab02 as Zzindenttab02,
      t.zzindenttab03 as Zzindenttab03,
      t.zzindenttab04 as Zzindenttab04,
      t.zzindenttab05 as Zzindenttab05
}
