#ifndef DQI_H
#define DQI_H

#include "PriorityQueue.h"

#define DQI_WINDOW_SIZE 100

/*******************************************************************************
* Variables.
*******************************************************************************/
bool     DQICalculatingFlag, DQISamplingFlag;
sample   DQIManager[DQI_WINDOW_SIZE];
uint16_t DQICounter, DQIEndId, DQIMax, DQIMin, DQIStartId, DQIValues[5];

/*******************************************************************************
* Function definitions.
*******************************************************************************/
void DQIAdd(sample);
void DQICalculate();
void DQIInit();
bool DQIStart();

/*******************************************************************************
* 
*******************************************************************************/
void DQIAdd(sample s) {
  if (DQICounter == 0) {
    DQIStartId = s.time;
  }

  DQIManager[DQICounter++] = s;

  if (DQICounter >= DQI_WINDOW_SIZE) {
    DQISamplingFlag    = FALSE;
    DQICalculatingFlag = TRUE;
    DQIEndId           = s.time;
    DQICalculate();
  }
  else {
    DQIMax = (s.data > DQIMax) ? s.data : DQIMax;
    DQIMin = (s.data < DQIMin) ? s.data : DQIMin;
  }
}

/*******************************************************************************
* 
*******************************************************************************/
void DQICalculate() {
  uint8_t  i, j, k, l;
  uint16_t diff, estimates[5][DQICounter + 1], nextId, prevId, rangeEnd,
           rangeStart;

  rangeStart = 0;

  for (i = 0; i < 5; i++) {
    for (j = 0; j <= DQI_WINDOW_SIZE; j++) {
      estimates[i][j] = 0;
    }
  }

  for (i = 0; i < 5; i++) {
    for (j = 0; j < DQI_WINDOW_SIZE; j++) {
      if (DQIManager[j].priority == 0) {
        estimates[i][j] = DQIManager[j].data;
        rangeEnd        = j;

        if (rangeStart != rangeEnd && rangeStart + 1 != rangeEnd) {
          prevId = rangeStart;

          for (k = rangeStart; k <= rangeEnd; k++) {
            if (DQIManager[k].priority <= i) {
              estimates[i][k] = DQIManager[k].data;
              nextId          = k;

              if (prevId != nextId && prevId + 1 != nextId) {
                for (l = prevId + 1; l < nextId; l++) {
                  diff            = DQIManager[nextId].data -
                                    DQIManager[prevId].data;
                  estimates[i][l] = DQIManager[prevId].data + (l - prevId) *
                                    diff / (nextId - prevId);
                  DQIValues[i]   += 1000 *
                                    (estimates[i][l] - DQIManager[l].data) /
                                    (2 * (DQIMax - DQIMin));
                }
              }

              prevId = k;
            }
          }
        }

        rangeStart = j;
      }
    }
  }

  sendDQIMsg();
}

/*******************************************************************************
* 
*******************************************************************************/
void DQIInit() {
  uint8_t i;

  DQICalculatingFlag = FALSE;
  DQICounter         = 0;
  DQIEndId           = 0;
  DQIMax             = 0;
  DQIMin             = 9999;
  DQISamplingFlag    = FALSE;
  DQIStartId         = 0;

  for (i = 0; i < 5; i++) {
    DQIValues[i] = 0;
  }
}

/*******************************************************************************
* 
*******************************************************************************/
bool DQIStart() {
  if (DQICalculatingFlag || DQISamplingFlag) {
    return FALSE;
  }

  DQICounter      = 0;
  DQISamplingFlag = TRUE;

  return TRUE;
}

#endif
