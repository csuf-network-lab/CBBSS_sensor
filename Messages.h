#ifndef MESSAGES_H
#define MESSAGES_H

/*******************************************************************************
* 
*******************************************************************************/
enum {
  AM_ACKMSG,
  AM_DQIMSG,
  AM_FEEDBACKMSG,
  AM_SENSORMSG
};

/*******************************************************************************
* msgType key
*   0 - DQI
*   1 - Sensor
*******************************************************************************/
typedef nx_struct ACKMsg {
  nx_uint16_t sensorId;
  nx_uint16_t msgId;
  nx_uint16_t msgType;
} ACKMsg;

/*******************************************************************************
* 
*******************************************************************************/
typedef nx_struct DQIMsg {
  nx_uint16_t sensorId;
  nx_uint16_t msgId;
  nx_uint16_t priorityCount;
  nx_uint16_t startId;
  nx_uint16_t endId;
  nx_uint16_t values[5];
} DQIMsg;

/*******************************************************************************
* 
*******************************************************************************/
typedef nx_struct FeedbackMsg {
  nx_uint16_t sensorId;
  nx_uint16_t feedback;
} FeedbackMsg;

/*******************************************************************************
* 
*******************************************************************************/
typedef nx_struct SensorMsg {
  nx_uint16_t sensorId;
  nx_uint16_t msgId;
  nx_uint8_t  tag;
  nx_uint16_t readings[5];
  nx_uint16_t times[5];
} SensorMsg;

#endif
