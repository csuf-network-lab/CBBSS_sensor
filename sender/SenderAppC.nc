#include "../Messages.h"
#include <Timer.h>

configuration SenderAppC {
  
}

implementation {
  components     ActiveMessageC;
  components new AMReceiverC(AM_FEEDBACKMSG);
  components new AMSenderC(AM_DQIMSG)    as AMSendDQI;
  components new AMSenderC(AM_SENSORMSG) as AMSendSensor;
  components     LedsC;
  components     MainC;
  components     SenderC                 as App;
  components new TimerMilliC()           as Timer;

  App.AMSendDQI       -> AMSendDQI;
  App.AMSendSensor    -> AMSendSensor;
  App.Boot            -> MainC;
  App.Leds            -> LedsC;
  App.PacketDQI       -> AMSendDQI;
  App.PacketSensor    -> AMSendSensor;
  App.ReceiveFeedback -> AMReceiverC;
  App.SplitControl    -> ActiveMessageC;
  App.Timer           -> Timer;
}
