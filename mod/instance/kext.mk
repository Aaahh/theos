ifeq ($(_THEOS_RULES_LOADED),)
include $(THEOS_MAKE_PATH)/rules.mk
endif

.PHONY: internal-kext-all_ internal-kext-stage_ internal-kext-compile

# Kexts don't have codesigning
_THEOS_CODESIGN_COMMANDLINE = true

# Bundle Setup
LOCAL_INSTALL_PATH ?= $(or $(strip $($(THEOS_CURRENT_INSTANCE)_INSTALL_PATH)),/System/Library/Extensions)
LOCAL_BUNDLE_NAME = $(or $($(THEOS_CURRENT_INSTANCE)_BUNDLE_NAME),$($(THEOS_CURRENT_INSTANCE)_KEXT_NAME),$(THEOS_CURRENT_INSTANCE))

_LOCAL_BUNDLE_FULL_NAME = $(LOCAL_BUNDLE_NAME).kext
_THEOS_SHARED_BUNDLE_BUILD_PATH = $(THEOS_OBJ_DIR)/$(_LOCAL_BUNDLE_FULL_NAME)
_THEOS_SHARED_BUNDLE_STAGE_PATH = $(THEOS_STAGING_DIR)$(LOCAL_INSTALL_PATH)/$(_LOCAL_BUNDLE_FULL_NAME)
_LOCAL_INSTANCE_TARGET := $(_LOCAL_BUNDLE_FULL_NAME)$(_THEOS_TARGET_BUNDLE_BINARY_SUBDIRECTORY)/$(THEOS_CURRENT_INSTANCE)
include $(THEOS_MAKE_PATH)/instance/shared/bundle.mk
# End Bundle Setup


_THEOS_INTERNAL_LDFLAGS += -Xlinker -kext -nostdlib -lkmodc++ -lkmod -lcc_kext -mlong-calls -stdlib=libc++
_THEOS_INTERNAL_CFLAGS += -pipe -nostdinc \
                                   -std=gnu99 -fno-builtin -Wno-trigraphs \
                                   -msoft-float -Os -fno-common -mkernel -finline \
                                   -fno-keep-inline-functions -Wreturn-type -Wunused-variable \
                                   -Wuninitialized -Wshorten-64-to-32 -DKERNEL -DKERNEL_PRIVATE \
                                   -DDRIVER_PRIVATE -DAPPLE -DNeXT \
                                   -fasm-blocks
_THEOS_INTERNAL_CCFLAGS += -pipe -fno-builtin -nostdinc \
                                   -Wno-trigraphs -fno-exceptions -fno-rtti -msoft-float \
                                   -mkernel -finline -fno-keep-inline-functions -Wreturn-type \
                                   -Wunused-variable -Wuninitialized -Wshorten-64-to-32 \
                                   -DKERNEL -DKERNEL_PRIVATE -DDRIVER_PRIVATE -DAPPLE -DNeXT \
                                   -fapple-kext -fasm-blocks -std=gnu++11 -stdlib=libc++ 

KEXT_SYSROOT ?= iPhoneOS.KernelDevelopmentKit
_THEOS_KEXT_DEVKIT		= $(KEXT_SYSROOT)
_THEOS_KEXT_INCLUDES		= -I $(_THEOS_KEXT_DEVKIT)/System/Library/Frameworks/IOKit.framework/Versions/A/Headers \
				  -I $(_THEOS_KEXT_DEVKIT)/System/Library/Frameworks/IOKit.framework/Versions/A/PrivateHeaders \
				  -I $(_THEOS_KEXT_DEVKIT)/System/Library/Frameworks/Kernel.framework/Headers \
				  -I $(_THEOS_KEXT_DEVKIT)/System/Library/Frameworks/Kernel.framework/PrivateHeaders \
				  -I $(_THEOS_KEXT_DEVKIT)/usr/include

# Kext includes
_THEOS_INTERNAL_CFLAGS		+= $(_THEOS_KEXT_INCLUDES)
_THEOS_INTERNAL_CCFLAGS		+= $(_THEOS_KEXT_INCLUDES)
_THEOS_INTERNAL_LDFLAGS		+= -L $(KEXT_SYSROOT)/usr/local/lib

ifeq ($(_THEOS_MAKE_PARALLEL_BUILDING), no)
internal-kext-all_:: $(_OBJ_DIR_STAMPS) shared-instance-bundle-all $(THEOS_OBJ_DIR)/$(_LOCAL_INSTANCE_TARGET)
else
internal-kext-all_:: $(_OBJ_DIR_STAMPS) shared-instance-bundle-all
	$(ECHO_NOTHING)$(MAKE) -f $(_THEOS_PROJECT_MAKEFILE_NAME) --no-print-directory --no-keep-going \
		internal-kext-compile \
		_THEOS_CURRENT_TYPE=$(_THEOS_CURRENT_TYPE) THEOS_CURRENT_INSTANCE=$(THEOS_CURRENT_INSTANCE) _THEOS_CURRENT_OPERATION=compile \
		THEOS_BUILD_DIR="$(THEOS_BUILD_DIR)" _THEOS_MAKE_PARALLEL=yes$(ECHO_END)

internal-kext-compile: $(THEOS_OBJ_DIR)/$(_LOCAL_INSTANCE_TARGET)
endif

$(eval $(call _THEOS_TEMPLATE_DEFAULT_LINKING_RULE,$(_LOCAL_INSTANCE_TARGET)))

internal-kext-stage_:: shared-instance-bundle-stage

