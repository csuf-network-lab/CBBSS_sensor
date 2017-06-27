#include "../Messages.h"
#include <Timer.h>

configuration ReceiverAppC {
  
}

implementation {
  // General
  components     LedsC;
  components     MainC;
  components     ReceiverC     as App;
  components new TimerMilliC() as Timer;

  App.Boot  -> MainC;
  App.Leds  -> LedsC;
  App.Timer -> Timer;

  // Radio
  components     ActiveMessageC;
  components new AMReceiverC(AM_DQIMSG)    as AMReceiverDQI;
  components new AMReceiverC(AM_SENSORMSG) as AMReceiverSensor;
  components new AMSenderC(AM_FEEDBACKMSG) as AMSenderFeedback;

  App.RadioAMPacketFeedback -> AMSenderFeedback;
  App.RadioControl          -> ActiveMessageC;
  App.RadioPacketFeedback   -> AMSenderFeedback;
  App.RadioReceiveDQI       -> AMReceiverDQI;
  App.RadioReceiveSensor    -> AMReceiverSensor;
  App.RadioSendFeedback     -> AMSenderFeedback;

  // Serial
  components SerialActiveMessageC;
  
  App.SerialAMPacketDQI     -> SerialActiveMessageC;
  App.SerialAMPacketSensor  -> SerialActiveMessageC;
  App.SerialControl         -> SerialActiveMessageC;
  App.SerialPacketDQI       -> SerialActiveMessageC;
  App.SerialPacketSensor    -> SerialActiveMessageC;
  App.SerialReceiveFeedback -> SerialActiveMessageC.Receive[AM_FEEDBACKMSG];
  App.SerialSendDQI         -> SerialActiveMessageC.AMSend[AM_DQIMSG];
  App.SerialSendSensor      -> SerialActiveMessageC.AMSend[AM_SENSORMSG];
}
