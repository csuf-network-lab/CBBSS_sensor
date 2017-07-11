#ifndef ACKQUEUE_H
#define ACKQUEUE_H

#include "../Messages.h"

//max sizes for ack queue in each message type
#define SEN_ACKQUEUE_SIZE 15
#define DQI_ACKQUEUE_SIZE 5
#define SEN_ATTEMPTS      3
#define DQI_ATTEMPTS      3

/*******************************************************************************
* A queue data structure for Acknowledgment messages. Uses the FIFO policy.
* Built using a linked list.
*******************************************************************************/

typedef struct Node {
  void*    data;
  uint16_t msgID;
  uint16_t attempt;
  Node*    next;
} Node;

typedef struct queueACK {
  Node*    front, rear;
  uint16_t count;
} queueACK;



/*******************************************************************************
* Queue function declarations for ACK messages.
*******************************************************************************/
uint16_t qACK_frontAttempts(queueACK*);
void*    qACk_front(queueACK*);
void     qACK_enqueue(queueACK*, void*, uint16_t, uint16_t);
void     qACK_init(queueACK*);
bool     qACK_dequeue(queueACK*, uint16_t);


/*******************************************************************************
* Returns the attempt number from the front node.
*
* @params
*   q - the queue
*
* @out
*   the attempt number
*******************************************************************************/
uint16_t qACK_frontAttempts(queueACK* q) {
  return q->front->attempt;
}

/*******************************************************************************
* Removes and returns the ACK message at the front of the queue.
*
* @params
*   q - the queue
*
* @out
*   the ACK message at the front of the queue
*******************************************************************************/
void* qDQI_front(queueACK* q) {

  void* d;
  Node* tempFront;

  // Cannot dequeue from an empty queue
  if (q->count == 0) {
    return NULL;
  }

  // Save the message at the front
  d = q->front->data;

  tempFront = q->Front;

  // Update
  q->front = q->front->next;

  q->count--;

  free(tempFront);

  // Return
  return d;
}

/*******************************************************************************
* Adds a message to the back of the queue.
*
* @params
*   q  - the queue
*   d  - the message to be added
*   ID - msgID
*******************************************************************************/
void qDQI_enqueue(queueACK* q, void* d, uint16_t ID, uint16_t attemptNum) {

  Node* temp    = (Node*)malloc(sizeof(Node));
  temp->data    = d;
  temp->msgId   = ID;
  temp->attempt = attemptNum;
  temp->next    = NULL;

  if (q->front == NULL && q->rear == NULL) {
    q->front = q->rear = temp;
    q->count++;
    return;
  }
  
  q->rear->next = temp;
  q->rear = temp;
  q->count++;

  return;
}

/*******************************************************************************
* Initializes the queue.
*
* @params
*   q - the queue
*******************************************************************************/
void qDQI_init(queueACK* q) {
  q->front = NULL;
  q->rear  = NULL;
  q->count = 0;
}

/*******************************************************************************
* removes a targetID from the queue.
*
* @params
*   q  - the queue
*   ID - target ID
*
* @out
*   true if the queue is empty, false otherwise
*******************************************************************************/
bool qACK_dequeue(queueACK*, uint16_t targetID) {
  Node* temp = q->front;
  Node* curr = temp;

  if (temp == NULL) return false;

  temp = temp->next;

  while (temp != NULL) {
    if (temp->msgId == targetID) {
      curr->next = temp->next;
      free(temp->data);
      free(temp);
      q->count--;

      return true;
    }
    else {
      curr = temp;
      temp = temp->next;
    }
  }

  return false;

}
