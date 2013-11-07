ifeq ($(THEOS_CURRENT_INSTANCE),)
	include $(THEOS_MODULE_PATH)/master/kext.mk
else
	ifeq ($(_THEOS_CURRENT_TYPE),kext)
		include $(THEOS_MODULE_PATH)/instance/kext.mk
	endif
endif
