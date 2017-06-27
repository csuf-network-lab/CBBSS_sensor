COMPONENT             = ReceiverAppC
CFLAGS               += -DCC2420_NO_ACKNOWLEDGEMENTS
CFLAGS               += -DCC2420_NO_ADDRESS_RECOGNITION
CFLAGS               += -DTASKLET_IS_TASK
TOSMAKE_PRE_EXE_DEPS += Msg.class
TOSMAKE_CLEAN_EXTRA   = *.class SensorMsg.java DQIMsg.java FeedbackMsg.java
TINYOS_ROOT_DIR      ?= ../../..

Msg.class: SensorMsg.java DQIMsg.java FeedbackMsg.java
	javac -target 1.5 -source 5 *.java -cp \*

SensorMsg.java:
	nescc-mig java $(CFLAGS) -java-classname=SensorMsg ../Messages.h SensorMsg -o $@

DQIMsg.java:
	nescc-mig java $(CFLAGS) -java-classname=DQIMsg ../Messages.h DQIMsg -o $@

FeedbackMsg.java:
	nescc-mig java $(CFLAGS) -java-classname=FeedbackMsg ../Messages.h FeedbackMsg -o $@

include $(TINYOS_ROOT_DIR)/Makefile.include
