#ifndef PQUEUE_H
#define PQUEUE_H

#define PQUEUE_SIZE 50

/*******************************************************************************
* A sample which contains a reading, timestamp and the priority level. Used as a
* heap.
*******************************************************************************/
typedef struct {
  uint8_t  priority;
  uint16_t data, time;
} sample;

/*******************************************************************************
* A priority queue based on a heap, tree data structure. Does not use index 0 of
* the heap. Therefore, it necessitates the plus one.
*******************************************************************************/
typedef struct {
  sample   heap[PQUEUE_SIZE + 1];
  uint16_t length;
} pqueue;

/*******************************************************************************
* Function declarations.
*******************************************************************************/
void   pq_exchange(pqueue*, uint16_t, uint16_t);
void   pq_init(pqueue*);
bool   pq_isEmpty(pqueue*);
sample pq_pop(pqueue*);
void   pq_push(pqueue*, sample);
void   pq_sink(pqueue*, uint16_t);
void   pq_swim(pqueue*, uint16_t);

/*******************************************************************************
* Exchanges the two elements specified by the two indices.
*
* @params
*   p - the priority queue
*   i - the index of the first element
*   j - the index of the second element
*******************************************************************************/
void pq_exchange(pqueue* p, uint16_t i, uint16_t j) {
  sample s;

  s          = p->heap[i];
  p->heap[i] = p->heap[j];
  p->heap[j] = s;
}

/*******************************************************************************
* Initializes the priority queue.
*
* @params
*   p - the priority queue
*******************************************************************************/
void pq_init(pqueue* p) {
  p->length = 0;
}

/*******************************************************************************
* Checks if the priority queue is empty.
*
* @params
*   p - the priority queue
*******************************************************************************/
bool pq_isEmpty(pqueue* p) {
  return p->length == 0;
}

/*******************************************************************************
* Removes the element at the front of the priority queue. This element has the
* highest priority. Rearranges the heap once again to ensure proper ordering.
*
* @params
*   p - the priority queue
*
* @out
*   returns the element at the front
*******************************************************************************/
sample pq_pop(pqueue* p) {
  sample s;

  // Cannot pop from an empty priority queue
  if (pq_isEmpty(p)) {
    s.data = 0;
    s.time = 0;

    return s;
  }

  // Save the data at the front
  s = p->heap[1];

  // Move the last node to the front
  pq_exchange(p, 1, p->length);

  // Decrease the length
  p->length--;

  // Enforce the order
  pq_sink(p, 1);

  // Return
  return s;
}

/*******************************************************************************
* Inserts the given sample into the priority queue. Enforces the priority
* ordering.
*
* @params
*   p - the priority queue
*   s - the sample to insert
*******************************************************************************/
void pq_push(pqueue* p, sample s) {
  // Cannot push new data if there is no more room
  if (p->length == PQUEUE_SIZE) {
    return;
  }

  // Update the length
  p->length++;

  // Place the data at the end
  p->heap[p->length] = s;

  // Enforce the order
  pq_swim(p, p->length);
}

/*******************************************************************************
* Moves the contents in the heap to their proper spot.
*
* @params
*   p - the priority queue
*   n - the index from which to start the sinking
*******************************************************************************/
void pq_sink(pqueue* p, uint16_t n) {
  uint16_t i;

  while (2 * n <= p->length) {
    i = 2 * n;

    if (i < p->length && p->heap[i].priority > p->heap[i + 1].priority) {
      i++;
    }

    if (p->heap[n].priority <= p->heap[i].priority) {
      break;
    }

    pq_exchange(p, n, i);

    n = i;
  }
}

/*******************************************************************************
* Exchanges the elements in the priority queue with their parents.
*
* @params
*   p - the priority queue
*   n - the index from which to start the swimming
*******************************************************************************/
void pq_swim(pqueue* p, uint16_t n) {
  while (n > 1 && p->heap[n / 2].priority > p->heap[n].priority) {
    pq_exchange(p, n / 2, n);

    n /= 2;
  }
}

#endif
