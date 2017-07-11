#include "../Messages.h"
#include "PriorityQueue.h"
#include "SenderData.h"
#include <Timer.h>
#include "AckQueue.h"

#define TIMER_PERIOD_MILLI 50
#define ACKTIMER_PERIOD_MILLI 10

module SenderC {
  uses interface AMSend        as AMSendACK;
  uses interface AMSend        as AMSendDQI;
  uses interface AMSend        as AMSendSensor;
  uses interface Boot;
  uses interface Leds;
  uses interface Packet        as PacketACK;
  uses interface Packet        as PacketDQI;
  uses interface Packet        as PacketSensor;
  uses interface Receive       as ReceiveACK;
  uses interface Receive       as ReceiveFeedback;
  uses interface SplitControl;
  uses interface Timer<TMilli> as Timer;
  uses interface ACKTimer<TMilli> as ACKTimer;
}

implementation {
  bool      radioBusy;
  message_t sensorPacket, dqiPacket, ackPacket;
  pqueue    nonPriorityBuffer, priorityBuffer;
  uint8_t   priorityCutoff;
  uint16_t  currentReading, msgId, nextNextReading, nextReading,
            prevPrevReading, prevReading, readingsIndex, ACKCounter;

  //ACK queues
  QueueACK* ACKQueue_DQI, ACKQueue_Sensor;


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
    ACKCounter      = 0;

    // Initialize the buffers
    pq_init(&nonPriorityBuffer);
    pq_init(&priorityBuffer);

    //initialize ACK queues
    ACKQueue_DQI    = (AckQueue*)malloc(sizeof(AckQueue));
    ACKQueue_Sensor = (AckQueue*)malloc(sizeof(AckQueue));
    qACK_init(ACKQueue_DQI);
    qACK_init(ACKQueue_Sensor);

    // Initialize the DQI variables
    DQIInit();

    // Start the controller
    call SplitControl.start();
  }

  /*****************************************************************************
  * This event is triggered every time the allotted, specified time interval has
  * elapsed.
  *****************************************************************************/
  event void ACKTimer.fired() {
    uint16_t   attemptNum;
    SensorMsg* senMsg, tempS;
    DQIMsq*    dqiMsg, tempD;

    if (ACKCounter % 2 == 0) {
      //check Sensor ACK queue
      if (ACKQueue_Sensor->count != 0) {
        attemptNum = qACK_frontAttempts(ACKQueue_Sensor);
        tempS      = (SensorMsg*)qACK_front(ACKQueue_Sensor);
        if (attemptNum < SEN_ATTEMPTS) {
          qACK_enqueue(ACKQueue_Sensor, (void*)tempS, temps->msgId, attemptNum + 1);
        }

        senMsg = (SensorMsg*)
              call PacketSensor.getPayload(&sensorPacket, sizeof(SensorMsg));

        // Ensure the reference is valid
        if (senMsg == NULL) {
          return;
        }
        
        for (i = 0; i < 5; i++) {
          senMsg->readings[i] = tempS->readings[i];
          senMsg->times[i]    = tempS->times[i];
        }

        // Set the remaining fields of the message
        senMsg->sensorId = tempS->sensorId;
        senMsg->msgId    = tempS->msgId;
        senMsg->tag      = tempS->tag;

        // Transmit the message
        error = call AMSendSensor.send
                (AM_BROADCAST_ADDR, &sensorPacket, sizeof(SensorMsg));
        if (error == SUCCESS) {
          radioBusy = TRUE;
          call Leds.led1Toggle();
        }

        if (attemptNum >= SEN_ATTEMPTS) {
          free(tempS);
        }
      }
    }
    else if (ACKCounter % 5 == 0) {
      //check DQI ACK queue
      if (ACKQueue_DQI->count != 0) {
        attemptNum = qACK_frontAttempts(ACKQueue_DQI);
        tempD      = (DQIMsg*)qACK_front(ACKQueue_DQI);
        if (attemptNum < DQI_ATTEMPTS) {
          qACK_enqueue(ACKQueue_DQI, (void*)tempD, tempD->msgId, attemptNum + 1);
        }

        dqiMsg = (DQIMsg*) call PacketDQI.getPayload(&dqiPacket, sizeof(DQIMsg));

        // Ensure the reference is valid
        if (dqiMsg == NULL) {
          return;
        }

        // Set the fields of the message
        for (i = 0; i < 5; i++) {
          dqiMsg->values[i] = tempD->values[i];
        }
        dqiMsg->sensorId      = tempD->sensorId;
        dqiMsg->msgId         = tempD->msgId;
        dqiMsg->priorityCount = tempD->priorityCount;
        dqiMsg->startId       = tempD->startId ;
        dqiMsg->endId         = tempD->endId;

        // Transmit the message
        error = call AMSendDQI.send(AM_BROADCAST_ADDR, &dqiPacket, sizeof(DQIMsg));
        if (error == SUCCESS) {
          radioBusy = TRUE;
          //call Leds.led2Toggle();
        }

        if (attemptNum >= DQI_ATTEMPTS) {
          free(tempD);
        }
      }
    }

    ACKCounter++

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
  * This event is triggered every time the receiver receives an ACK message.
  *
  * @params
  *   message - ?
  *   payload - ?
  *   length  - ?
  *
  * @out
  *****************************************************************************/
  event message_t*
  ReceiveACK.receive(message_t* message, void* payload, uint8_t length) {
    ACKMsg* msg;

    // Ensure we received a feedback message
    if (length == sizeof(ACKMsg)) {
      // Cast the payload to the correct data type
      msg = (ACKMsg*) payload;

      // Ensure the feedback is for this sensor
      if (msg->sensorId == TOS_NODE_ID) {
        // Perform feedback
        if (msg->msgType == 0) {
          qACK_dequeue(ACKQueue_DQI, msg_msgID);
        }
        else if (msg->msgType == 1) {
          qACK_dequeue(ACKQueue_Sensor, msg_msgID);
        }

        // Toggle the red LED
        //call Leds.led0Toggle();
      }
    }

    return message;
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

        //send ACK
        ACKMsg* ack;

        (ACKMsg*) call PacketACK.getPayload(&ackPacket, sizeof(ACKMsg));

        ack->sensorId = TOS_NODE_ID;
        ack->msgId    = msg->msgId;
        ack->msgType  = 2;

        error = call AMSendACK.send(AM_BROADCAST_ADDR, &ackPacket, sizeof(ACKMsg));
        if (error == SUCCESS) {
          radioBusy = TRUE;
        //call Leds.led2Toggle();
        }
        // Toggle the red LED
        //call Leds.led0Toggle();
      }
    }

    return message;
  }

  /*****************************************************************************
  * This event is triggered every time the active message sender for ACK
  * messages has finished sending a packet. Updates the busy flag to false so
  * other components can use the radio. It also toggles the blue LED for visual
  * confirmation.
  *
  * @params
  *   message - ?
  *   error   - ?
  *****************************************************************************/
  event void AMSendDQI.sendDone(message_t* message, error_t error) {
    if (&ackPacket == message) {
      radioBusy = FALSE;
      //call Leds.led2Toggle();
    }
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
      call ACKTimer.startPeriodic(ACKTIMER_PERIOD_MILLI);
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
    DQIMsg*  msgACK;
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

    //add the mesage to the ack queue
    msgACK = (DQIMsg*)malloc(sizeof(DQIMsg));
    msgACK->sensorId      = msg->sensorId; 
    msgACK->msgId         = msg->msgId; 
    msgACK->priorityCount = msg->priorityCount; 
    msgACK->startId       = msg->startId; 
    msgACK->endId         = msg->endId; 

    //remove front if full
    if (ACKQueue_DQI->count == DQI_ACKQUEUE_SIZE) qDQI_front(ACKQueue_DQI);

    qACK_enqueue(ACKQueue_DQI, (void*)msgACK, msg->msgId, 0);


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
    SensorMsg* msg, msgACK;
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

    //add the mesage to the ack queue
    msgACK = (SensorMsg*)malloc(sizeof(SensorMsg));
    msgACK->sensorId      = msg->sensorId; 
    msgACK->msgId         = msg->msgId;
    msgACK->tag           = msg->msg->tag; 
    for (i = 0; i < 5; i++) {
      msgACK->readings[i] = msg->readings[i];
      msgACK->times[i]    = msg->times[i];
    }

    //remove front if full
    if (ACKQueue_Sensor->count == SEN_ACKQUEUE_SIZE) qDQI_front(ACKQueue_Sensor);

    qACK_enqueue(ACKQueue_Sensor, (void*)msgACK, msg->msgId, 0);
  }
}
