

# create data with small FOV problem
$(TESTS_OUT)/shepplogan-smallfov-ksp.ra: traj scale phantom
	set -e ; mkdir $(TESTS_TMP) ; cd $(TESTS_TMP)					;\
	$(TOOLDIR)/traj -x128 -y128 t.ra						;\
	$(TOOLDIR)/scale 1.5 t.ra t2.ra							;\
	$(TOOLDIR)/phantom -s8 -k -t t.ra $@						;\
	rm *.ra ; cd .. ; rmdir $(TESTS_TMP)

$(TESTS_OUT)/cart-pattern.ra: ones resize repmat reshape extract ones join
	set -e ; mkdir $(TESTS_TMP) ; cd $(TESTS_TMP)					;\
	$(TOOLDIR)/ones 3 1 1 1 o.ra							;\
	$(TOOLDIR)/resize 2 2 o.ra o2.ra						;\
	$(TOOLDIR)/repmat 3 64 o2.ra o3.ra						;\
	$(TOOLDIR)/reshape 12 128 1 o3.ra o4.ra						;\
	$(TOOLDIR)/extract 2 0 52 o4.ra o5.ra						;\
	$(TOOLDIR)/ones 3 1 1 24 oc.ra							;\
	$(TOOLDIR)/join 2 o5.ra oc.ra o5.ra $@						;\
	rm *.ra ; cd .. ; rmdir $(TESTS_TMP)

tests/test-pics: fmac fft nrmse ecalib pics $(TESTS_OUT)/shepplogan-smallfov-ksp.ra $(TESTS_OUT)/cart-pattern.ra
	set -e ; mkdir $(TESTS_TMP) ; cd $(TESTS_TMP)							;\
	$(TOOLDIR)/fmac $(TESTS_OUT)/shepplogan-smallfov-ksp.ra $(TESTS_OUT)/cart-pattern.ra ku.ra	;\
	$(TOOLDIR)/ecalib ku.ra se.ra			 						;\
	$(TOOLDIR)/pics -i100 ku.ra se.ra xu.ra		 						;\
	$(TOOLDIR)/fmac -s16 xu.ra se.ra xsp.ra								;\
	$(TOOLDIR)/fft -u 7 xsp.ra xsp2.ra								;\
	$(TOOLDIR)/nrmse -s -t 0.03 $(TESTS_OUT)/shepplogan-smallfov-ksp.ra xsp2.ra		 	;\
	rm *.ra ; cd .. ; rmdir $(TESTS_TMP)
	touch $@

tests/test-enlive: fmac fft nrmse nlinv $(TESTS_OUT)/shepplogan-smallfov-ksp.ra $(TESTS_OUT)/cart-pattern.ra
	set -e ; mkdir $(TESTS_TMP) ; cd $(TESTS_TMP)							;\
	$(TOOLDIR)/fmac $(TESTS_OUT)/shepplogan-smallfov-ksp.ra $(TESTS_OUT)/cart-pattern.ra ku.ra	;\
	$(TOOLDIR)/nlinv -m2 -i12 -U -S -N ku.ra xu2.ra sn.ra			 			;\
	$(TOOLDIR)/fmac -s16 xu2.ra sn.ra xsn.ra							;\
	$(TOOLDIR)/fft -u 7 xsn.ra xsn2.ra								;\
	$(TOOLDIR)/nrmse -s -t 0.03 $(TESTS_OUT)/shepplogan-smallfov-ksp.ra xsn2.ra		 	;\
	rm *.ra ; cd .. ; rmdir $(TESTS_TMP)
	touch $@


TESTS += tests/test-pics tests/test-enlive
