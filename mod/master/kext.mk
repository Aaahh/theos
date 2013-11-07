KEXT_NAME := $(strip $(KEXT_NAME))

ifeq ($(_THEOS_RULES_LOADED),)
include $(THEOS_MAKE_PATH)/rules.mk
endif

internal-all:: $(KEXT_NAME:=.all.kext.variables);

internal-stage:: $(KEXT_NAME:=.stage.kext.variables);

KEXTS_WITH_SUBPROJECTS = $(strip $(foreach kext,$(KEXT_NAME),$(patsubst %,$(kext),$(call __schema_var_all,$(kext)_,SUBPROJECTS))))
ifneq ($(KEXTS_WITH_SUBPROJECTS),)
internal-clean:: $(KEXTS_WITH_SUBPROJECTS:=.clean.kext.subprojects)
endif

$(KEXT_NAME):
	@$(MAKE) -f $(_THEOS_PROJECT_MAKEFILE_NAME) --no-print-directory --no-keep-going $@.all.kext.variables

