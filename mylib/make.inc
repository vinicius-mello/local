MYLIB = ~/local/mylib
#MYLIB = ~/mylib

uname_S := $(shell sh -c 'uname -s 2>/dev/null || echo not')

ifneq (,$(findstring MINGW,$(uname_S)))
  include $(MYLIB)/mingw.inc
endif
ifneq (,$(findstring Darwin,$(uname_S)))
  include $(MYLIB)/macosx.inc
else
  include $(MYLIB)/linux.inc
endif
