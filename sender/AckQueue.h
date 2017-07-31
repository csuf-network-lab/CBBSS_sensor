#ifndef ACKQUEUE_H
#define ACKQUEUE_H

#include "../Messages.h"

//max sizes for ack queue in each message type
#define SEN_ACKQUEUE_SIZE 15
#define DQI_ACKQUEUE_SIZE 5
#define SEN_ATTEMPTS      2
#define DQI_ATTEMPTS      2

/*******************************************************************************
* A queue data structure for Acknowledgment messages. Uses the FIFO policy.
* Built using a linked list.
*******************************************************************************/

typedef struct Node {
  void*    data;
  uint16_t msgID;
  uint16_t attempt;
  struct Node*    next;
} Node;

typedef struct queueACK {
  Node*    front, *rear;
  uint16_t count;
} queueACK;



/*******************************************************************************
* Queue function declarations for ACK messages.
*******************************************************************************/
uint16_t qACK_frontAttempts(queueACK*);
void*    qACK_front(queueACK*);
void     qACK_enqueue(queueACK*, void*, uint16_t, uint16_t);
void     qACK_init(queueACK*);
bool     qACK_dequeue(queueACK*, uint16_t);
void     qACK_pop(queueACK*);


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
void* qACK_front(queueACK* q) {

  void* d;
  //Node* tempFront;

  // Cannot dequeue from an empty queue
  if (q->front == NULL) {
    return NULL;
  }

  // Save the message at the front
  d = q->front->data;

  //update attempt count
  q->front->attempt += 1;

  //tempFront = q->front;

  // Update
  //q->front = q->front->next;

  //q->count--;

  //free(tempFront);

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
void qACK_enqueue(queueACK* q, void* d, uint16_t ID, uint16_t attemptNum) {

  Node* temp    = (Node*)malloc(sizeof(Node));
  temp->data    = d;
  temp->msgID   = ID;
  temp->attempt = attemptNum;
  temp->next    = NULL;

  if (q->front == NULL) {
    q->front = q->rear = temp;
    q->count++;
    return;
  }
  
  (q->rear)->next = temp;
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
void qACK_init(queueACK* q) {
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
bool qACK_dequeue(queueACK* q, uint16_t targetID) {
  Node* temp = q->front;
  Node* curr = temp;

  if (temp == NULL) return FALSE;

  if (curr->msgID == targetID) {
      q->front = temp->next;
      free(curr->data);
      free(curr);
      q->count = q->count - 1;

      return TRUE;
  }

  temp = temp->next;

  while (temp != NULL) {
    if (temp->msgID == targetID) {
      curr->next = temp->next;
      free(temp->data);
      free(temp);
      q->count = q->count - 1;

      return TRUE;
    }
    else {
      curr = temp;
      temp = temp->next;
    }
  }

  return FALSE;

}

void qACK_pop(queueACK* q) {
  Node* tempFront;

  if (q->front == NULL) return;

  tempFront = q->front;
  q->front = q->front->next;

  free(tempFront->data);
  free(tempFront);

  q->count -= 1;

  return;
}

#endif