#ifndef QUEUE_H
#define QUEUE_H

#include "../Messages.h"

#define QUEUE_SIZE 15

/*******************************************************************************
* A queue data structure for DQI messages. Uses the FIFO policy.
*******************************************************************************/
typedef struct {
  int16_t  front, rear;
  uint16_t count;
  DQIMsg   msgs[QUEUE_SIZE + 1];
} queueDQI;

/*******************************************************************************
* Queue function declarations for DQI messages.
*******************************************************************************/
DQIMsg qDQI_dequeue(queueDQI*);
void   qDQI_enqueue(queueDQI*, DQIMsg);
void   qDQI_init(queueDQI*);
bool   qDQI_isEmpty(queueDQI*);

/*******************************************************************************
* Removes and returns the DQI message at the front of the queue.
*
* @params
*   q - the queue
*
* @out
*   the DQI message at the front of the queue
*******************************************************************************/
DQIMsg qDQI_dequeue(queueDQI* q) {
  DQIMsg d;

  // Cannot dequeue from an empty queue
  if (qDQI_isEmpty(q)) {
    d.startId = 69;
    return d;
  }

  // Save the message at the front
  d = q->msgs[q->front];

  // Update
  q->front++;
  if (q->front == QUEUE_SIZE) {
    q->front = 0;
  }
  q->count--;

  // Return
  return d;
}

/*******************************************************************************
* Adds a DQI message to the back of the queue.
*
* @params
*   q - the queue
*   d - the DQI message to be added
*******************************************************************************/
void qDQI_enqueue(queueDQI* q, DQIMsg d) {
  // Full queue, remove front (oldest) message to make room
  if (q->count == QUEUE_SIZE) {
    qDQI_dequeue(q);
  }

  // Update and insert
  if (q->rear == QUEUE_SIZE - 1) {
    q->rear = -1;
  }
  q->rear++;
  q->msgs[q->rear] = d;
  q->count++;
}

/*******************************************************************************
* Initializes the queue.
*
* @params
*   q - the queue
*******************************************************************************/
void qDQI_init(queueDQI* q) {
  q->front = 0;
  q->rear  = -1;
  q->count = 0;
}

/*******************************************************************************
* Checks if the queue is empty.
*
* @params
*   q - the queue
*
* @out
*   true if the queue is empty, false otherwise
*******************************************************************************/
bool qDQI_isEmpty(queueDQI* q) {
  return q->count == 0;
}

/*******************************************************************************
* A queue data structure for sensor messages. Uses the FIFO policy.
*******************************************************************************/
typedef struct {
  int16_t   front, rear;
  uint16_t  count;
  SensorMsg msgs[QUEUE_SIZE + 1];
} queueSensor;

/*******************************************************************************
* Queue function declarations for sensor messages.
*******************************************************************************/
SensorMsg qSensor_dequeue(queueSensor*);
void      qSensor_enqueue(queueSensor*, SensorMsg);
void      qSensor_init(queueSensor*);
bool      qSensor_isEmpty(queueSensor*);

/*******************************************************************************
* Removes and returns the sensor message at the front of the queue.
*
* @params
*   q - the queue
*
* @out
*   the sensor message at the front of the queue
*******************************************************************************/
SensorMsg qSensor_dequeue(queueSensor* q) {
  SensorMsg s;

  // Cannot dequeue from an empty queue
  if (qSensor_isEmpty(q)) {
    s.tag = 69;
    return s;
  }

  // Save the message at the front
  s = q->msgs[q->front];

  // Update
  q->front++;
  if (q->front == QUEUE_SIZE) {
    q->front = 0;
  }
  q->count--;

  // Return
  return s;
}

/*******************************************************************************
* Adds a sensor message to the back of the queue.
*
* @params
*   q - the queue
*   s - the sensor message to be added
*******************************************************************************/
void qSensor_enqueue(queueSensor* q, SensorMsg s) {
  // Full queue, remove front (oldest) message to make room
  if (q->count == QUEUE_SIZE) {
    qSensor_dequeue(q);
  }

  // Update and insert
  if (q->rear == QUEUE_SIZE - 1) {
    q->rear = -1;
  }
  q->rear++;
  q->msgs[q->rear] = s;
  q->count++;
}

/*******************************************************************************
* Initializes the queue.
*
* @params
*   q - the queue
*******************************************************************************/
void qSensor_init(queueSensor* q) {
  q->front = 0;
  q->rear  = -1;
  q->count = 0;
}

/*******************************************************************************
* Checks if the queue is empty.
*
* @params
*   q - the queue
*
* @out
*   true if the queue is empty, false otherwise
*******************************************************************************/
bool qSensor_isEmpty(queueSensor* q) {
  return q->count == 0;
}


/*******************************************************************************
* A queue data structure for ACK messages. Uses the FIFO policy.
*******************************************************************************/
typedef struct {
  int16_t  front, rear;
  uint16_t count;
  ACKMsg   msgs[QUEUE_SIZE + 1];
} queueACK;

/*******************************************************************************
* Queue function declarations for ACK messages.
*******************************************************************************/
ACKMsg qACK_dequeue(queueACK*);
void   qACK_enqueue(queueACK*, ACKMsg);
void   qACK_init(queueACK*);
bool   qACK_isEmpty(queueACK*);

/*******************************************************************************
* Removes and returns the ACK message at the front of the queue. 
*
* @params
*   q - the queue
*
* @out
*   the ACK message at the front of the queue
*******************************************************************************/
ACKMsg qACK_dequeue(queueACK* q) {
  ACKMsg d;

  // Cannot dequeue from an empty queue
  if (qACK_isEmpty(q)) {
    return d;
  }

  // Save the message at the front
  d = q->msgs[q->front];

  // Update
  q->front++;
  if (q->front == QUEUE_SIZE) {
    q->front = 0;
  }
  q->count--;

  // Return
  return d;
}

/*******************************************************************************
* Adds a ACK message to the back of the queue.
*
* @params
*   q - the queue
*   d - the ACK message to be added
*******************************************************************************/
void qACK_enqueue(queueACK* q, ACKMsg d) {
  // Full queue, remove front (oldest) message to make room
  if (q->count == QUEUE_SIZE) {
    qACK_dequeue(q);
  }

  // Update and insert
  if (q->rear == QUEUE_SIZE - 1) {
    q->rear = -1;
  }
  q->rear++;
  q->msgs[q->rear] = d;
  q->count++;
}

/*******************************************************************************
* Initializes the queue.
*
* @params
*   q - the queue
*******************************************************************************/
void qACK_init(queueACK* q) {
  q->front = 0;
  q->rear  = -1;
  q->count = 0;
}

/*******************************************************************************
* Checks if the queue is empty.
*
* @params
*   q - the queue
*
* @out
*   true if the queue is empty, false otherwise
*******************************************************************************/
bool qACK_isEmpty(queueACK* q) {
  return q->count == 0;
}


#endif
