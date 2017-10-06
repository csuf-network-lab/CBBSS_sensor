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
  components new AMReceiverC(AM_ACKMSG)    as AMReceiverACK;
  components new AMSenderC(AM_FEEDBACKMSG) as AMSenderFeedback;
  components new AMSenderC(AM_ACKMSG)      as AMSenderACK;

  App.RadioAMPacketFeedback -> AMSenderFeedback;
  App.RadioAMPacketACK      -> AMSenderACK;
  App.RadioControl          -> ActiveMessageC;
  App.RadioPacketFeedback   -> AMSenderFeedback;
  App.RadioPacketACK        -> AMSenderACK;
  App.RadioReceiveDQI       -> AMReceiverDQI;
  App.RadioReceiveSensor    -> AMReceiverSensor;
  App.RadioReceiveACK       -> AMReceiverACK;
  App.RadioSendFeedback     -> AMSenderFeedback;
  App.RadioSendACK          -> AMSenderACK;

  // Serial
  components SerialActiveMessageC;
  
  App.SerialAMPacketDQI     -> SerialActiveMessageC;
  App.SerialAMPacketSensor  -> SerialActiveMessageC;
  App.SerialAMPacketACK     -> SerialActiveMessageC;
  App.SerialControl         -> SerialActiveMessageC;
  App.SerialPacketDQI       -> SerialActiveMessageC;
  App.SerialPacketSensor    -> SerialActiveMessageC;
  App.SerialPacketACK       -> SerialActiveMessageC;
  App.SerialReceiveFeedback -> SerialActiveMessageC.Receive[AM_FEEDBACKMSG];
  App.SerialReceiveACK      -> SerialActiveMessageC.Receive[AM_ACKMSG];
  App.SerialSendDQI         -> SerialActiveMessageC.AMSend[AM_DQIMSG];
  App.SerialSendSensor      -> SerialActiveMessageC.AMSend[AM_SENSORMSG];
  App.SerialSendACK         -> SerialActiveMessageC.AMSend[AM_ACKMSG];

}
