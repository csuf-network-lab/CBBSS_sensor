#include "../Messages.h"
#include <Timer.h>

configuration SenderAppC {
  
}

implementation {
  components     ActiveMessageC;
  components new AMReceiverC(AM_FEEDBACKMSG) as AMReciveFeed;
  components new AMReceiverC(AM_ACKMSG)      as AMReceiveACK;
  components new AMSenderC(AM_ACKMSG)    as AMSendACK;
  components new AMSenderC(AM_DQIMSG)    as AMSendDQI;
  components new AMSenderC(AM_SENSORMSG) as AMSendSensor;
  components     LedsC;
  components     MainC;
  components     SenderC                 as App;
  components new TimerMilliC()           as Timer;
  components new TimerMilliC()           as ACKTimer;


  App.AMSendACK       -> AMSendACK;
  App.AMSendDQI       -> AMSendDQI;
  App.AMSendSensor    -> AMSendSensor;
  App.Boot            -> MainC;
  App.Leds            -> LedsC;
  App.PacketACK       -> AMSendACK;
  App.PacketDQI       -> AMSendDQI;
  App.PacketSensor    -> AMSendSensor;
  App.ReceiveACK      -> AMReceiveACK;
  App.ReceiveFeedback -> AMReceiveFeed;
  App.SplitControl    -> ActiveMessageC;
  App.Timer           -> Timer;
  App.ACKTimer        -> ACKTimer;
}
