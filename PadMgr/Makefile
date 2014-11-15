THEOS_DEVICE_IP = 192.168.250.213
ARCHS = armv7
TARGET = iphone:latest:5.0

include theos/makefiles/common.mk


APPLICATION_NAME = PadMgr
PadMgr_FILES = main.m \
AppDelegate.mm \
ViewController.mm \
V_loading.mm \
O_logic.mm \
VC_select_path.mm

PadMgr_FRAMEWORKS = UIKit CoreGraphics Foundation

include $(THEOS_MAKE_PATH)/application.mk

after-stage::
	$(ECHO_NOTHING)chmod 4755 $(THEOS_STAGING_DIR)/Applications/PadMgr.app/PadMgr$(ECHO_END)
	$(ECHO_NOTHING)chmod 0755 $(THEOS_STAGING_DIR)/Applications/PadMgr.app/PadMgrBash$(ECHO_END)
