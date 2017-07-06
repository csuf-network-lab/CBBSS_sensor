#include "../Messages.h"
#include "PriorityQueue.h"
#include "SenderData.h"
#include <Timer.h>

#define TIMER_PERIOD_MILLI 50

module SenderC {
  uses interface AMSend        as AMSendDQI;
  uses interface AMSend        as AMSendSensor;
  uses interface Boot;
  uses interface Leds;
  uses interface Packet        as PacketDQI;
  uses interface Packet        as PacketSensor;
  uses interface Receive       as ReceiveFeedback;
  uses interface SplitControl;
  uses interface Timer<TMilli> as Timer;
}

implementation {
  bool      radioBusy;
  message_t sensorPacket, dqiPacket;
  pqueue    nonPriorityBuffer, priorityBuffer;
  uint8_t   priorityCutoff;
  uint16_t  currentReading, msgId, nextNextReading, nextReading,
            prevPrevReading, prevReading, readingsIndex;

  uint8_t calculatePriority();
  void    getReading();
  void    sendDQIMsg();
  void    sendSensorMsg();

  // Forgive me Parku, for I have sinned...
  #include "DQI.h"

  /*****************************************************************************
  * The starting point of the program. Starts the controller, which in turn,
  * starts up the other components. Initializes global variables.
  *****************************************************************************/
  event void Boot.booted() {
    // Initialize global variables
    currentReading  = 0;
    msgId           = 1;
    nextNextReading = jogDataX[1];
    nextReading     = jogDataX[0];
    prevPrevReading = 0;
    prevReading     = 0;
    priorityCutoff  = 1;
    radioBusy       = FALSE;
    readingsIndex   = 2;

    // Initialize the buffers
    pq_init(&nonPriorityBuffer);
    pq_init(&priorityBuffer);

    // Initialize the DQI variables
    DQIInit();

    // Start the controller
    call SplitControl.start();
  }

  /*****************************************************************************
  * This event is triggered every time the allotted, specified time interval has
  * elapsed.
  *****************************************************************************/
  event void Timer.fired() {
    uint8_t randomNum;

    // Start the DQI process
    if (!DQISamplingFlag) {
      DQIStart();
    }

    // Generate a random number in range [0,9]
    randomNum = rand() % 10;

    // Decide which action to take
    if (randomNum <= 6) {   // 70%
      getReading();
    }
    else {                  // 30%
      sendSensorMsg();
    }
  }

  /*****************************************************************************
  * This event is triggered every time the receiver receives a feedback message.
  *
  * @params
  *   message - ?
  *   payload - ?
  *   length  - ?
  *
  * @out
  *****************************************************************************/
  event message_t*
  ReceiveFeedback.receive(message_t* message, void* payload, uint8_t length) {
    FeedbackMsg* msg;

    // Ensure we received a feedback message
    if (length == sizeof(FeedbackMsg)) {
      // Cast the payload to the correct data type
      msg = (FeedbackMsg*) payload;

      // Ensure the feedback is for this sensor
      if (msg->sensorId == TOS_NODE_ID) {
        // Perform feedback
        if (msg->feedback == 1) {
          priorityCutoff++;
        }

        // Toggle the red LED
        call Leds.led0Toggle();
      }
    }

    return message;
  }

  /*****************************************************************************
  * This event is triggered every time the active message sender for DQI
  * messages has finished sending a packet. Updates the busy flag to false so
  * other components can use the radio. It also toggles the blue LED for visual
  * confirmation.
  *
  * @params
  *   message - ?
  *   error   - ?
  *****************************************************************************/
  event void AMSendDQI.sendDone(message_t* message, error_t error) {
    if (&dqiPacket == message) {
      radioBusy = FALSE;
      call Leds.led2Toggle();
    }
  }

  /*****************************************************************************
  * This event is triggered every time the active message sender for sensor
  * messages has finished sending a packet. Updates the busy flag to false so
  * other components can use the radio. It also toggles the green LED for visual
  * confirmation.
  *
  * @params
  *   message - ?
  *   error   - ?
  *****************************************************************************/
  event void AMSendSensor.sendDone(message_t* message, error_t error) {
    if (&sensorPacket == message) {
      radioBusy = FALSE;
      call Leds.led1Toggle();
    }
  }

  /*****************************************************************************
  * This event is triggered once the controller has finished being initialized.
  * This means that all other components are now ready. Starts the timer if the
  * initialization was successful. Otherwise, attempt to start the controller
  * again.
  *
  * @params
  *   error - ?
  *****************************************************************************/
  event void SplitControl.startDone(error_t error) {
    if (error == SUCCESS) {
      call Timer.startPeriodic(TIMER_PERIOD_MILLI);
    }
    else {
      call SplitControl.start();
    }
  }

  /*****************************************************************************
  * This event is triggered once the controller has finished being stopped. This
  * means that all other components are also stopped.
  *
  * @params
  *   error - ?
  *****************************************************************************/
  event void SplitControl.stopDone(error_t error) {

  }

  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  /*****************************************************************************
  * Calculates the priority level for the current reading.
  *****************************************************************************/
  uint8_t calculatePriority() {
    uint8_t  priority;
    uint16_t diff0, diff1, diff2, diff3;

    // Calculate differences
    diff0 = abs(prevReading - prevPrevReading);
    diff1 = abs(currentReading - prevReading);
    diff2 = abs(nextReading - currentReading);
    diff3 = abs(nextNextReading - nextReading);

    // The first two readings always have the highest priority
    if (prevPrevReading == 0) {
      priority = 0;
    }

    // Filtered min/max
    else if (currentReading > prevReading     &&
             currentReading > nextReading     &&
             prevReading    > prevPrevReading &&
             nextReading    > nextNextReading) {
      priority = 0;
    }
    else if (currentReading < prevReading     &&
             currentReading < nextReading     &&
             prevReading    < prevPrevReading &&
             nextReading    < nextNextReading) {
      priority = 0;
    }

    // Local max cases
    else if (currentReading > prevReading && currentReading > nextReading) {
      priority = 1;
    }
    else if (currentReading >= prevReading && currentReading > nextReading) {
      priority = 1;
    }
    else if (currentReading > prevReading && currentReading >= nextReading) {
      priority = 1;
    }

    // Local min cases
    else if (currentReading < prevReading && currentReading < nextReading) {
      priority = 1;
    }
    else if (currentReading <= prevReading && currentReading < nextReading) {
      priority = 1;
    }
    else if (currentReading < prevReading && currentReading <= nextReading) {
      priority = 1;
    }

    // Inflection point cases
    else if (diff1 < diff0 && diff2 < diff3) {
      priority = 2;
    }
    else if (diff1 > diff0 && diff2 > diff3) {
      priority = 2;
    }

    // Large change in slope cases
    else if (diff1 < diff0 / 2 && diff1 < diff2 / 2) {
      priority = 3;
    }
    else if (diff1 > 2* diff0 && diff1 > 2 * diff2) {
      priority = 3;
    }

    // All other cases
    else {
      priority = 4;
    }

    // Done
    return priority;
  }

  /*****************************************************************************
  * Grabs the next reading from the hard-coded array of values. Places the
  * reading in one of two buffers, depending on the calculated priority level.
  * Updates the 5 past readings for priority calculation.
  *****************************************************************************/
  void getReading() {
    sample   s;
    uint8_t  priority;
    uint16_t reading;

    // Grab the next reading
    reading = jogDataX[readingsIndex];

    // Update the past readings
    prevPrevReading = prevReading;
    prevReading     = currentReading;
    currentReading  = nextReading;
    nextReading     = nextNextReading;
    nextNextReading = reading;

    // Calculate the priority level
    priority = calculatePriority();

    // Create the sample
    s.priority = priority;
    s.data     = currentReading;
    s.time     = readingsIndex - 2;

    // Add the sample to the DQI manager
    if (DQISamplingFlag) {
      DQIAdd(s);
    }

    // Store the sample in the correct priority queue buffer
    if (priority <= priorityCutoff) {
      pq_push(&priorityBuffer, s);
    }
    else {
      pq_push(&nonPriorityBuffer, s);
    }

    // Update the index
    readingsIndex = (readingsIndex + 1) % READINGS_SIZE;
  }

  /*****************************************************************************
  * 
  *****************************************************************************/
  void sendDQIMsg() {
    DQIMsg*  msg;
    error_t  error;
    uint8_t  i;
    uint16_t priorityCount;

    // Do not transmit if the radio is already busy
    if (radioBusy) {
      return;
    }

    // Get a reference to the DQI packet
    msg = (DQIMsg*) call PacketDQI.getPayload(&dqiPacket, sizeof(DQIMsg));

    // Ensure the reference is valid
    if (msg == NULL) {
      return;
    }

    // Calculate the priority count
    for (i = 0, priorityCount = 0; i < DQI_WINDOW_SIZE; i++) {
      if (DQIManager[i].priority <= priorityCutoff) {
        priorityCount++;
      }
    }

    // Set the fields of the message
    for (i = 0; i < 5; i++) {
      msg->values[i] = DQIValues[i];
    }
    msg->sensorId      = TOS_NODE_ID;
    msg->msgId         = msgId++;
    msg->priorityCount = priorityCount;
    msg->startId       = DQIStartId;
    msg->endId         = DQIEndId;

    // Transmit the message
    error = call AMSendDQI.send(AM_BROADCAST_ADDR, &dqiPacket, sizeof(DQIMsg));
    if (error == SUCCESS) {
      radioBusy = TRUE;
      call Leds.led2Toggle();
    }

    // Reset the DQI variables
    DQIInit();
  }

  /*****************************************************************************
  * Broadcasts a sensor message. The readings are first pulled from the priority
  * buffer. Once that buffer has less than 5 readings, the message will pull
  * readings from the non-priority buffer.
  *****************************************************************************/
  void sendSensorMsg() {
    bool       priority;
    error_t    error;
    sample     s;
    SensorMsg* msg;
    uint8_t    i;

    // Do not transmit if the radio is already busy or if both buffers have less
    // than 5 readings available
    if (radioBusy ||
       (nonPriorityBuffer.length < 5 && priorityBuffer.length < 5)) {
      return;
    }

    // Get a reference to the sensor packet
    msg = (SensorMsg*)
          call PacketSensor.getPayload(&sensorPacket, sizeof(SensorMsg));

    // Ensure the reference is valid
    if (msg == NULL) {
      return;
    }

    // Determine which buffer to read from
    priority = priorityBuffer.length >= 5;

    // Retrieve 5 readings from the buffer
    for (i = 0; i < 5; i++) {
      if (priority) {
        s = pq_pop(&priorityBuffer);
      }
      else {
        s = pq_pop(&nonPriorityBuffer);
      }

      msg->readings[i] = s.data;
      msg->times[i]    = s.time;
    }

    // Set the remaining fields of the message
    msg->sensorId = TOS_NODE_ID;
    msg->msgId    = msgId++;
    msg->tag      = priority;

    // Transmit the message
    error = call AMSendSensor.send
            (AM_BROADCAST_ADDR, &sensorPacket, sizeof(SensorMsg));
    if (error == SUCCESS) {
      radioBusy = TRUE;
      call Leds.led1Toggle();
    }
  }
}
