########################################
#  This file was generated by hdlmake  #
#  http://ohwr.org/projects/hdl-make/  #
########################################

PROJECT := None
ISE_CRAP := *.b None_summary.html *.tcl None.bld None.cmd_log *.drc None.lso *.ncd None.ngc None.ngd None.ngr None.pad None.par None.pcf None.prj None.ptwx None.stx None.syr None.twr None.twx None.gise None.unroutes None.ut None.xpi None.xst None_bitgen.xwbt None_envsettings.html None_guide.ncd None_map.map None_map.mrp None_map.ncd None_map.ngm None_map.xrpt None_ngdbuild.xrpt None_pad.csv None_pad.txt None_par.xrpt None_summary.xml None_usage.xml None_xst.xrpt usage_statistics_webtalk.html webtalk.log webtalk_pn.xml run.tcl

#target for performing local synthesis
local:
		echo "project open $(PROJECT)" > run.tcl
		echo "process run {Generate Programming File} -force rerun_all" >> run.tcl
		xtclsh run.tcl


#target for cleaing all intermediate stuff
clean:
		rm -f $(ISE_CRAP)
		rm -rf xst xlnx_auto_*_xdb iseconfig _xmsgs _ngo

#target for cleaning final files
mrproper:
		rm -f *.bit *.bin *.mcs

