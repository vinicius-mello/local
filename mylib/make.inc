MYLIB = ~/local/mylib
#MYLIB = ~/mylib

uname_S := $(shell sh -c 'uname -s 2>/dev/null || echo not')

ifneq (,$(findstring MINGW,$(uname_S)))
  include $(MYLIB)/mingw.inc
else
  include $(MYLIB)/linux.inc
endif
