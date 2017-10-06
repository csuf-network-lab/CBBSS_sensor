#ifndef DQI_H
#define DQI_H

#include "PriorityQueue.h"
#include <stdlib.h>
#include <stdio.h>

#define DQI_WINDOW_SIZE 200

/*******************************************************************************
* Variables.
*******************************************************************************/
bool     DQICalculatingFlag, DQISamplingFlag;
sample   DQIManager[DQI_WINDOW_SIZE];
uint16_t DQICounter, DQIEndId, DQIMax, DQIMin, DQIStartId;
uint16_t DQIValues[5];

/*******************************************************************************
* Function definitions.
*******************************************************************************/
void DQIAdd(sample);
void DQICalculate();
void DQIInit();
bool DQIStart();
int abs1(int);

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
  uint16_t nextId, prevId, rangeEnd,
           rangeStart, estimates[4][DQI_WINDOW_SIZE], estimate;
  int diff;
  uint16_t templ;

  for (i = 0; i < 5; i++) {
    DQIValues[i] = 0;
  }


  for (i = 0; i < 5; i++) {
    for (j = 0; j < DQI_WINDOW_SIZE; j++) {
      estimates[i][j] = 0;
    }
  }
  rangeStart = rangeEnd = 0;
  for (k = 0; k < 5; k++) {
    for (i = 0; i < DQI_WINDOW_SIZE; i++) {
      if (DQIManager[i].priority == 0) {
        estimates[k][i] = DQIManager[i].data;
        rangeEnd        = i;

        if (rangeStart != rangeEnd && rangeStart + 1 != rangeEnd) {
          prevId = rangeStart;

          for (l = rangeStart; l <= rangeEnd; l++) {
            if (DQIManager[l].priority <= k) {
              estimates[k][l] = DQIManager[l].data;
              nextId          = l;

              if (prevId != nextId && prevId + 1 != nextId) {
                for (j = prevId + 1; j < nextId; j++) {
                  diff = (DQIManager[nextId].data -
                                    DQIManager[prevId].data);
                  estimate = DQIManager[prevId].data + (j - prevId)*(diff / (int)(nextId - prevId));
                  
                  estimates[k][j] = estimate;
                  templ = 1000.0* abs((double)(estimates[k][j] - DQIManager[j].data)) / abs((double)((DQIManager[rangeEnd].data - DQIManager[rangeStart].data)));

                  //(10000*(abs((double)(estimates[k][j] - DQIManager[j].data)) /
                  //                  (abs((double)((DQIManager[rangeEnd].data - DQIManager[rangeStart].data)*1.0)))));
                  DQIValues[k] += templ;
                  //printf("temp = %d dqi = %d \n\r",templ, DQIValues[k]);
                }
              }

              prevId = l;
            }
          }
        }

        rangeStart = i;
      }
    }
  }
  //for (i = 0; i < 100; i++) printf("estimates = %d\n\r", estimates[0][i]);

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

double abs(double x)
{
    return x>=0?x:-x;
}

int abs1(int x)
{
    return x>=0?x:-x;
}


#endif
