TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = App

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ChatGPTOverlay
ChatGPTOverlay_FILES = Tweak.xm
ChatGPTOverlay_FRAMEWORKS = UIKit WebKit AuthenticationServices

include $(THEOS_MAKEFILES)/tweak.mk
