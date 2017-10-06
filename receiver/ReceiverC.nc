#include "Queue.h"
#include <Timer.h>

#define TIMER_PERIOD_MILLI 10

module ReceiverC {
  // General
  uses {
    interface Boot;
    interface Leds;
    interface Timer<TMilli> as Timer;
  }

  // Radio
  uses {
    interface AMPacket     as RadioAMPacketFeedback;
    interface AMSend       as RadioSendFeedback;
    interface Packet       as RadioPacketFeedback;
    interface AMPacket     as RadioAMPacketACK;
    interface AMSend       as RadioSendACK;
    interface Packet       as RadioPacketACK;
    interface Receive      as RadioReceiveDQI;
    interface Receive      as RadioReceiveSensor;
    interface Receive      as RadioReceiveACK;
    interface SplitControl as RadioControl;
  }

  // Serial
  uses {
    interface AMPacket     as SerialAMPacketDQI;
    interface AMPacket     as SerialAMPacketSensor;
    interface AMPacket     as SerialAMPacketACK;
    interface AMSend       as SerialSendDQI;
    interface AMSend       as SerialSendSensor;
    interface AMSend       as SerialSendACK;
    interface Packet       as SerialPacketDQI;
    interface Packet       as SerialPacketSensor;
    interface Packet       as SerialPacketACK;
    interface Receive      as SerialReceiveFeedback;
    interface Receive      as SerialReceiveACK;
    interface SplitControl as SerialControl;
  }
}

implementation {
  bool        radioBusy, serialBusy;
  message_t   packetDQI, packetFeedback, packetSensor, packetACKtoPC, packetACKtoSensor;
  queueDQI    bufferDQI;
  queueSensor bufferSensor;
  queueACK    bufferACK;

  void sendDQIMsg();
  void sendFeedbackMsg(FeedbackMsg*);
  void sendSensorMsg();
  void sendACKtoPC();
  void sendACKtoSensor(ACKMsg*);

  /*****************************************************************************
  * The starting point of the program. Starts the controllers, which in turn,
  * starts up the other components. Initializes global variables.
  *****************************************************************************/
  event void Boot.booted() {
    // Initialize the variables
    radioBusy  = FALSE;
    serialBusy = FALSE;

    // Initialize the buffers
    qDQI_init(&bufferDQI);
    qSensor_init(&bufferSensor);
    qACK_init(&bufferACK);

    // Start the controllers
    call RadioControl.start();
    call SerialControl.start();
  }

  /*****************************************************************************
  * This event is triggered every time the allotted, specified time interval has
  * elapsed. Calls the serial transmission of any messages in the buffers.
  * Priority is given to ACK messages.
  *****************************************************************************/
  event void Timer.fired() {

    //transmit a ACK message if the ACK buffer is not empty
    if (!qACK_isEmpty(&bufferACK)) {
      sendACKtoPC();
    }
    // Otherwise, transmit a DQI message if the DQI buffer is not empty
    else if (!qDQI_isEmpty(&bufferDQI)) {
      sendDQIMsg();
    }
    // Otherwise, transmit a sensor message if the sensor buffer is not empty
    else if (!qSensor_isEmpty(&bufferSensor)) {
      sendSensorMsg();
    }

  }

  /*****************************************************************************
  * This event is triggered every time the receiver receives a DQI message.
  * Stores the message into a buffer for serial transmission.
  *
  * @params
  *   message - ?
  *   payload - ?
  *   length  - ?
  *
  * @out
  *****************************************************************************/
  event message_t*
  RadioReceiveDQI.receive(message_t* message, void* payload, uint8_t length) {
    DQIMsg* msg;

    // Ensure it's a DQI message
    if (length == sizeof(DQIMsg)) {
      // Cast the payload to the correct data type
      msg = (DQIMsg*) payload;

      // Add it to the buffer
      qDQI_enqueue(&bufferDQI, *msg);

      // Toggle the green LED
      call Leds.led1Toggle();
    }

    // Done
    return message;
  }

  /*****************************************************************************
  * This event is triggered every time the receiver receives a sensor message.
  *
  * @params
  *   message - ?
  *   payload - ?
  *   length  - ?
  *
  * @out
  *****************************************************************************/
  event message_t*
  RadioReceiveSensor.receive(message_t* message, void* payload, uint8_t length) {
    SensorMsg* msg;

    // Ensure it's a sensor message
    if (length == sizeof(SensorMsg)) {
      // Cast the payload to the correct data type
      msg = (SensorMsg*) payload;

      // Add it to the buffer
      qSensor_enqueue(&bufferSensor, *msg);

      // Toggle the green LED
      call Leds.led1Toggle();
    }

    // Done
    return message;
  }

    /*****************************************************************************
  * This event is triggered every time the receiver receives a ACK message.
  * Stores the message into a buffer for serial transmission.
  *
  * @params
  *   message - ?
  *   payload - ?
  *   length  - ?
  *
  * @out
  *****************************************************************************/
  event message_t*
  RadioReceiveACK.receive(message_t* message, void* payload, uint8_t length) {
    ACKMsg* msg;

    // Ensure it's a ACK message
    if (length == sizeof(ACKMsg)) {
      // Cast the payload to the correct data type
      msg = (ACKMsg*) payload;

      // Add it to the buffer
      qACK_enqueue(&bufferACK, *msg);

      // Toggle the green LED
      call Leds.led1Toggle();
    }

    // Done
    return message;
  }

  /*****************************************************************************
  * This event is triggered every time the receiver receives a feedback message.
  * Sends the feedback message through the radio.
  *
  * @params
  *   message - ?
  *   payload - ?
  *   length  - ?
  *
  * @out
  *****************************************************************************/
  event message_t*
  SerialReceiveFeedback.receive(message_t* message, void* payload, uint8_t length) {
    FeedbackMsg* msg;

    // Ensure it's a DQI message
    if (length == sizeof(FeedbackMsg)) {
      // Cast the payload to the correct data type
      msg = (FeedbackMsg*) payload;

      // Send the feedback message if the radio is not busy
      if (!radioBusy) {
        sendFeedbackMsg(msg);
      }
    }

    // Done
    return message;
  }

  /*****************************************************************************
  * This event is triggered every time the receiver receives a ACK message.
  * Sends the ACK message through the radio.
  *
  * @params
  *   message - ?
  *   payload - ?
  *   length  - ?
  *
  * @out
  *****************************************************************************/
  event message_t*
  SerialReceiveACK.receive(message_t* message, void* payload, uint8_t length) {
    ACKMsg* msg;

    // Ensure it's a ACK message
    if (length == sizeof(ACKMsg)) {
      // Cast the payload to the correct data type
      msg = (ACKMsg*) payload;

      // Send the feedback message if the radio is not busy
      if (!radioBusy) {
        sendACKtoSensor(msg);
      }
    }

    // Done
    return message;
  }

  /*****************************************************************************
  * This event is triggered every time the active message sender for feedback
  * messages has finished sending a packet through the radio. Updates the busy
  * flag to false so other components can use the radio.
  *
  * @params
  *   message - ?
  *   error   - ?
  *****************************************************************************/
  event void RadioSendFeedback.sendDone(message_t* message, error_t error) {
    if (message == &packetFeedback) {
      radioBusy = FALSE;
      call Leds.led0Toggle();
    }
  }

  /*****************************************************************************
  * This event is triggered every time the active message sender for ACK
  * messages has finished sending a packet through the radio. Updates the busy
  * flag to false so other components can use the radio.
  *
  * @params
  *   message - ?
  *   error   - ?
  *****************************************************************************/
  event void RadioSendACK.sendDone(message_t* message, error_t error) {
    if (message == &packetACKtoSensor) {
      radioBusy = FALSE;
      call Leds.led0Toggle();
    }
  }

  /*****************************************************************************
  * This event is triggered every time the active message sender for DQI
  * messages has finished sending a packet through the serial port. Updates the
  * busy flag to false so other components can use the serial port.
  *
  * @params
  *   message - ?
  *   error   - ?
  *****************************************************************************/
  event void SerialSendDQI.sendDone(message_t* message, error_t error) {
    if (message == &packetDQI) {
      serialBusy = FALSE;
      call Leds.led2Toggle();
    }
  }

  /*****************************************************************************
  * This event is triggered every time the active message sender for sensor
  * messages has finished sending a packet through the serial port. Updates the
  * busy flag to false so other components can use the serial port.
  *
  * @params
  *   message - ?
  *   error   - ?
  *****************************************************************************/
  event void SerialSendSensor.sendDone(message_t* message, error_t error) {
    if (message == &packetSensor) {
      serialBusy = FALSE;
      call Leds.led2Toggle();
    }
  }

  /*****************************************************************************
  * This event is triggered every time the active message sender for ACK
  * messages has finished sending a packet through the serial port. Updates the
  * busy flag to false so other components can use the serial port.
  *
  * @params
  *   message - ?
  *   error   - ?
  *****************************************************************************/
  event void SerialSendACK.sendDone(message_t* message, error_t error) {
    if (message == &packetACKtoPC) {
      serialBusy = FALSE;
      call Leds.led2Toggle();
    }
  }

  /*****************************************************************************
  * This event is triggered once the radio controller has finished being
  * initialized. This means that all other radio components are now ready.
  * Starts the timer if the initialization was successful. Otherwise, attempt to
  * start the controller again.
  *
  * @params
  *   error - ?
  *****************************************************************************/
  event void RadioControl.startDone(error_t error) {
    if (error == SUCCESS) {
      call Timer.startPeriodic(TIMER_PERIOD_MILLI);
    }
    else {
      call RadioControl.start();
    }
  }

  /*****************************************************************************
  * This event is triggered once the serial controller has finished being
  * initialized. This means that all other serial components are now ready. If
  * the initialization was not successful, restart the serial controller.
  *
  * @params
  *   error - ?
  *****************************************************************************/
  event void SerialControl.startDone(error_t error) {
    if (error != SUCCESS) {
      call SerialControl.start();
    }
  }

  /*****************************************************************************
  * This event is triggered once the radio controller has finished being
  * stopped. This means that all other radio components are also stopped.
  *
  * @params
  *   error - ?
  *****************************************************************************/
  event void RadioControl.stopDone(error_t error) {

  }

  /*****************************************************************************
  * This event is triggered once the serial controller has finished being
  * stopped. This means that all other serial components are also stopped.
  *
  * @params
  *   error - ?
  *****************************************************************************/
  event void SerialControl.stopDone(error_t error) {

  }

  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  /*****************************************************************************
  * Transmits the DQI message at the front of the DQI buffer to the serial port.
  *****************************************************************************/
  void sendDQIMsg() {
    DQIMsg  *msgSend, msgReceive;
    error_t error;
    uint8_t i;

    // Do not transmit if the serial port is already busy
    if (serialBusy) {
      return;
    }

    // Get a reference to the DQI packet
    msgSend = (DQIMsg*)
              call SerialPacketDQI.getPayload(&packetDQI, sizeof(DQIMsg));

    // Ensure the reference is valid
    if (msgSend == NULL) {
      return;
    }

    // Grab the DQI message to send from the front of the buffer
    msgReceive = qDQI_dequeue(&bufferDQI);

    // Copy the fields
    msgSend->sensorId      = msgReceive.sensorId;
    msgSend->msgId         = msgReceive.msgId;
    msgSend->priorityCount = msgReceive.priorityCount;
    msgSend->startId       = msgReceive.startId;
    msgSend->endId         = msgReceive.endId;
    for (i = 0; i < 5; i++) {
      msgSend->values[i] = msgReceive.values[i];
    }

    // Transmit the message
    error = call SerialSendDQI.send
            (AM_BROADCAST_ADDR, &packetDQI, sizeof(DQIMsg));
    if (error == SUCCESS) {
      serialBusy = TRUE;
      call Leds.led2Toggle();
    }
  }

  /*****************************************************************************
  * Broadcasts the feedback message through the radio.
  *****************************************************************************/
  void sendFeedbackMsg(FeedbackMsg* msgReceive) {
    error_t     error;
    FeedbackMsg *msgSend;

    // Get a reference to the feedback packet
    msgSend = (FeedbackMsg*)
              call RadioPacketFeedback.getPayload
              (&packetFeedback, sizeof(FeedbackMsg));

    // Ensure the reference is valid
    if (msgSend == NULL) {
      return;
    }

    // Copy the fields
    msgSend->sensorId = msgReceive->sensorId;
    msgSend->dropCount = msgReceive->dropCount;

    // Transmit the message
    error = call RadioSendFeedback.send
            (AM_BROADCAST_ADDR, &packetFeedback, sizeof(FeedbackMsg));
    if (error == SUCCESS) {
      radioBusy = TRUE;
      call Leds.led0Toggle();
    }
  }

  /*****************************************************************************
  * Transmits the sensor message at the front of the sensor buffer to the serial
  * port.
  *****************************************************************************/
  void sendSensorMsg() {
    error_t   error;
    SensorMsg *msgSend, msgReceive;
    uint8_t   i;

    // Do not transmit if the serial port is already busy
    if (serialBusy) {
      return;
    }

    // Get a reference to the sensor packet
    msgSend = (SensorMsg*)
              call SerialPacketSensor.getPayload
              (&packetSensor, sizeof(SensorMsg));

    // Ensure the reference is valid
    if (msgSend == NULL) {
      return;
    }

    // Grab the sensor message to send from the front of the buffer
    msgReceive = qSensor_dequeue(&bufferSensor);

    // Copy the fields
    msgSend->sensorId = msgReceive.sensorId;
    msgSend->msgId    = msgReceive.msgId;
    msgSend->tag      = msgReceive.tag;
    for (i = 0; i < 5; i++) {
      msgSend->readings[i] = msgReceive.readings[i];
      msgSend->times[i]    = msgReceive.times[i];
    }

    // Transmit the message
    error = call SerialSendSensor.send
            (AM_BROADCAST_ADDR, &packetSensor, sizeof(SensorMsg));
    if (error == SUCCESS) {
      serialBusy = TRUE;
      call Leds.led2Toggle();
    }
  }

  /*****************************************************************************
  * Transmits the ACK message at the front of the ACK buffer to the serial port.
  *****************************************************************************/
  void sendACKtoPC() {
    ACKMsg  *msgSend, msgReceive;
    error_t error;
    uint8_t i;

    // Do not transmit if the serial port is already busy
    if (serialBusy) {
      return;
    }

    // Get a reference to the DQI packet
    msgSend = (ACKMsg*)
              call SerialPacketACK.getPayload(&packetACKtoPC, sizeof(ACKMsg));

    // Ensure the reference is valid
    if (msgSend == NULL) {
      return;
    }

    // Grab the DQI message to send from the front of the buffer
    msgReceive = qACK_dequeue(&bufferACK);

    // Copy the fields
    msgSend->sensorId      = msgReceive.sensorId;
    msgSend->msgId         = msgReceive.msgId;
    msgSend->msgType       = msgReceive.msgType;

    // Transmit the message
    error = call SerialSendACK.send
            (AM_BROADCAST_ADDR, &packetACKtoPC, sizeof(ACKMsg));
    if (error == SUCCESS) {
      serialBusy = TRUE;
      call Leds.led2Toggle();
    }
  }

  /*****************************************************************************
  * Broadcasts the ACK message through the radio.
  *****************************************************************************/
  void sendACKtoSensor(ACKMsg* msgReceive) {
    error_t     error;
    ACKMsg      *msgSend;

    // Get a reference to the feedback packet
    msgSend = (ACKMsg*) call RadioPacketACK.getPayload(&packetACKtoSensor, sizeof(ACKMsg));

    // Ensure the reference is valid
    if (msgSend == NULL) {
      return;
    }

    // Copy the fields
    msgSend->sensorId      = msgReceive->sensorId;
    msgSend->msgId         = msgReceive->msgId;
    msgSend->msgType       = msgReceive->msgType;

    // Transmit the message
    error = call RadioSendACK.send
            (AM_BROADCAST_ADDR, &packetACKtoSensor, sizeof(ACKMsg));
    if (error == SUCCESS) {
      radioBusy = TRUE;
      call Leds.led0Toggle();
    }
  }
}
