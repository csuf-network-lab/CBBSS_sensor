public class SensorProfile {
  /*****************************************************************************
  * 
  *****************************************************************************/
  private class DataPoint {
    boolean isEstimate, isPriority;
    int     data, id;

    public DataPoint(int i) {
      data       = 0;
      id         = i;
      isEstimate = true;
      isPriority = false;
    }
  }

  /*****************************************************************************
  * 
  *****************************************************************************/
  private              DataPoint[] buffer;
  private              double      desiredDQI;
  private              double[]    valuesDQI;
  private static final int         WINDOW_SIZE = 100;
  private              int         bufferOffset, dataRate, endId, importance,
                                   priorityCount, priorityLevel, samplingRate,
                                   sensorId, startId, duplicates = 0;
  private              String      dataType;

  /*****************************************************************************
  * 
  *****************************************************************************/
  public SensorProfile(int sId) {
    buffer        = new DataPoint[1100];
    bufferOffset  = 0;
    dataRate      = 0;
    dataType      = "motion";
    desiredDQI    = 0.9;
    endId         = 0;
    importance    = 1;
    priorityCount = 0;
    priorityLevel = 1;
    samplingRate  = 10;
    sensorId      = sId;
    startId       = -1;
    valuesDQI     = new double[5];

    for (sId = 0; sId < 1100; sId++) {
      buffer[sId] = new DataPoint(sId);
    }

    for (sId = 0; sId < 5; sId++) {
      valuesDQI[sId] = 0.0;
    }
  }

  /*****************************************************************************
  * 
  *****************************************************************************/
  public void addData(int data, int id, boolean priority) {
    int position;

    position = id + bufferOffset;

    if(buffer[position].isEstimate == false) duplicates++;

    buffer[position].data       = data;
    buffer[position].id         = id;
    buffer[position].isEstimate = false;
    buffer[position].isPriority = priority;

    if (position % 100 == 0) System.out.println("duplicates = " + duplicates/5 + "\n\n\n");
  }

  /*****************************************************************************
  * 
  *****************************************************************************/
  public FeedbackMsg calculateEstimatedDQI() {
    double estDQI, nonPriorityDQI, priorityDQI;
    int    countNP, countP, endOffset, i, startOffset;

    countNP        = 0;
    countP         = 0;
    endOffset      = endId + bufferOffset;
    estDQI         = 0.0;
    nonPriorityDQI = 0.0;
    priorityDQI    = 0.0;
    startOffset    = startId + bufferOffset;

    for (i = 0; i <= priorityLevel; i++) {
      priorityDQI += valuesDQI[i];
    }

    for (i = priorityLevel + 1; i < 5; i++) {
      nonPriorityDQI += valuesDQI[i];
    }
    nonPriorityDQI /= 5 - priorityLevel;

    if (startOffset == -1) {
      return null;
    }

    for (i = startOffset; i < endOffset; i++) {
      if (!buffer[i].isEstimate) {
        if (buffer[i].isPriority) {
          countP++;
        }
        else {
          countNP++;
        }
      }
    }

    /*System.out.println("countP = " + countP);
    System.out.println("countNP = " + countNP);
    System.out.println("priorityCount = " + priorityCount);*/

    estDQI = priorityDQI * countP / priorityCount +
             nonPriorityDQI * countNP / (WINDOW_SIZE - priorityCount);

    System.out.println("Estimated DQI = " + estDQI + "\n");

    return generateFeedback(estDQI);
  }

  /*****************************************************************************
  * 
  *****************************************************************************/
  public FeedbackMsg generateFeedback(double estDQI) {
    FeedbackMsg msg;
    int         feedback;

    if (estDQI < desiredDQI) {
      feedback = 1;
    }
    else {
      feedback = 0;
    }

    msg = new FeedbackMsg();
    msg.set_sensorId(sensorId);
    msg.set_feedback(feedback);

    return msg;
  }

  /*****************************************************************************
  * 
  *****************************************************************************/
  public int getImportance() {
    return importance;
  }

  /*****************************************************************************
  * 
  *****************************************************************************/
  public int getPriorityLevel() {
    return priorityLevel;
  }

  /*****************************************************************************
  * 
  *****************************************************************************/
  public int getSensorId() {
    return sensorId;
  }

  /*****************************************************************************
  * 
  *****************************************************************************/
  public FeedbackMsg receiveDQIMsg(DQIMsg msg) {
    double[] zzz;
    int      i;
    int[]    temp;

    temp = new int[5];
    zzz  = new double[5];

    /*if (msg.get_startId() != -1) {
      calculateEstimatedDQI();
    }*/

    temp = msg.get_values();
    for (i = 0; i < 5; i++) {
      valuesDQI[i] = temp[i];
    }

    endId         = msg.get_endId();
    priorityCount = msg.get_priorityCount();
    startId       = msg.get_startId();

    zzz[0] = 1 - valuesDQI[0] / (1000.0 * WINDOW_SIZE);

    for (i = 1; i < 5; i++) {
      zzz[i] = (valuesDQI[i - 1] - valuesDQI[i]) / (1000.0 * WINDOW_SIZE);
    }

    /*System.out.println("zzz");
    for (i = 0; i < 5; i++) {
      System.out.print(zzz[i] + " ");
    }
    System.out.println("\n");*/

    for (i = 0; i < 5; i++) {
      valuesDQI[i] = zzz[i];
    }

    return calculateEstimatedDQI();
  }

  /*****************************************************************************
  * 
  *****************************************************************************/
  public void setBufferOffset(int offset) {
    bufferOffset = offset;
  }

  /*****************************************************************************
  * 
  *****************************************************************************/
  public void setImportance(int imp) {
    importance = imp;
  }

  /*****************************************************************************
  * 
  *****************************************************************************/
  public void setPriorityLevel(int lvl) {
    priorityLevel = lvl;
  }

  /*****************************************************************************
  * 
  *****************************************************************************/
  public void setSensorId(int sId) {
    sensorId = sId;
  }
}
