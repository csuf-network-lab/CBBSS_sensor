public class SensorProfile {
  /*****************************************************************************
  * 
  *****************************************************************************/
  private class DataPoint {
    boolean isEstimate, isPriority;
    double     data;
    int        id;

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
  private              double[]    valuesDQI, estDQIAr, actualDQIAr;
  private static final int         WINDOW_SIZE = 200;
  private              int         bufferOffset, dataRate, endId, importance,
                                   priorityCount, priorityLevel, samplingRate,
                                   sensorId, startId, duplicates, dqiCount;
  private              int         feedbackCounter, calcCount;                                 
  private              String      dataType;
  private              int[]       startIds, endIds, msgIds;

  /*****************************************************************************
  * 
  *****************************************************************************/
  public SensorProfile(int sId) {
    buffer        = new DataPoint[10000];
    bufferOffset  = 0;
    dataRate      = 0;
    dataType      = "motion";
    desiredDQI    = 0.985;
    endId         = 0;
    importance    = 1;
    priorityCount = 0;
    priorityLevel = 0;
    samplingRate  = 10;
    sensorId      = sId;
    startId       = -1;
    duplicates    = 0;
    dqiCount      = 0;
    feedbackCounter = 0;
    calcCount     = 0;
    valuesDQI     = new double[5];
    estDQIAr      = new double[50];
    actualDQIAr   = new double[50];
    msgIds        = new int[50];

    for (sId = 0; sId < 10000; sId++) {
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

    if(id > 10000) {System.out.print("id = " + id); return;}

    position = id + bufferOffset;

    if(buffer[position].isEstimate == false) duplicates++;

    buffer[position].data       = data ;
    buffer[position].id         = id;
    buffer[position].isEstimate = false;
    buffer[position].isPriority = priority;

    /*Only call calculateDQI when varifying ADQI values with experimental data
    if (position  > 100 + 1000 * (1 +calcCount)){
      calcCount++;
      calculateDQI(((position/1000)-1)*5, (position/1000)*5);
    }
    */
  }

  /*****************************************************************************
  * 
  *****************************************************************************/
  public FeedbackMsg calculateEstimatedDQI(int msgID) {
  //if (dqiCount > 0 && msgID == msgIds[dqiCount -1]) return null;

    double estDQI, nonPriorityDQI, priorityDQI;
    int    countNP, countP, endOffset, i, startOffset, lostData;

    //get values from previous DQI message
    countNP        = 0;
    countP         = 0;
    priorityDQI = nonPriorityDQI = 0;
    endOffset      = endId;
    estDQI         = 0.0;
    startOffset    = startId;

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


    for (i = 0; i <= priorityLevel; i++) {
      priorityDQI += valuesDQI[i];
    }

    for (i = priorityLevel + 1; i < 5; i++) {
      nonPriorityDQI += valuesDQI[i];
    }

    estDQI = priorityDQI + nonPriorityDQI * countNP / (WINDOW_SIZE - priorityCount);
    estDQIAr[dqiCount] = estDQI;

    System.out.println("estimate" + estDQI + " \n" );

    
    dqiCount++;

    //System.out.println("estimate Count " + estimateCount + " \n" );
    lostData = WINDOW_SIZE - (countNP + countP)-1;
    return generateFeedback(lostData);
  }

  /*****************************************************************************
  * 
  *****************************************************************************/
  public FeedbackMsg generateFeedback(int lostData) {
    FeedbackMsg msg;
    /*
    int         feedback;
    
    if(dqiCount == 1) return null;

    if (estDQI < desiredDQI) {
      feedbackCounter++;
    }
    //else {
      //feedbackCounter--;
    //}
    if (feedbackCounter > 1) {
      feedback = 1;
      if (priorityLevel < 3) priorityLevel++;
      feedbackCounter = 0;
    }
    //else if (feedbackCounter < -5) {
      //feedback = 2;
      //if (priorityLevel > 0)priorityLevel--;
      //feedbackCounter = 0;
    //}
    else {
      return null;
    }
    */

    msg = new FeedbackMsg();
    msg.set_sensorId(sensorId);
    msg.set_dropCount(lostData);

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
  public void receiveDQIMsg(DQIMsg msg) {
    double[] zzz;
    int      i, pLevel;
    int[]    temp;

    temp = new int[5];
    zzz  = new double[5];

    /*if (msg.get_startId() != -1) {
      calculateEstimatedDQI();
    }*/

    temp = msg.get_values();
    for (i = 0; i < 5; i++) {
      valuesDQI[i] = (double)(temp[i]/1000.0);
    }

    endId         = (int)msg.get_endId();
    priorityCount = (int)msg.get_priorityCount();
    startId       = (int)msg.get_startId();
    pLevel        = (int)msg.get_priorityCutoff();

    //System.out.println("priority = " + priorityCount + "\n");
    if (pLevel != priorityLevel) {
      System.out.println("new PLevel" + pLevel + "\n");
      priorityLevel = pLevel;
    }

    zzz[0] = 1 - valuesDQI[0] / (WINDOW_SIZE);

    for (i = 1; i < 5; i++) {
      zzz[i] = (valuesDQI[i - 1] - valuesDQI[i]) / (WINDOW_SIZE);
    }

    /*System.out.println("zzz");
    for (i = 0; i < 5; i++) {
      System.out.print(zzz[i] + " ");
    }
    System.out.println("\n");*/

    for (i = 0; i < 5; i++) {
      valuesDQI[i] = zzz[i];
    }
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

  public double absol(double x) {
    if (x < 0) x = -x;

    return x;
  }



  //*****************************************************************************
  //*****************************************************************************

  //For testing purposes to calculate ADQI after data has
  //been received by the aggregator

  //necessary to verify ADQI levels depedning on pre-loaded sensor data
  public void calculateDQI(int first, int last) {
    //actual dqi
    double [] estimates; 
    int [] priorityLevels;
    int previousKnown, nextKnown;
    int start, end;

    start = first * 200;
    end  = (last) * 200;

    estimates      = new double[1100];
    priorityLevels = new int[1100];

    for (int i = 0; i < 1000; i++) {
      priorityLevels[i] = getDataPLevel(i%600);
    }

    for (int i = 0; i < 5; i++) actualDQIAr[i] = 0;

    int estimateCount = 0;
    previousKnown = nextKnown = 0;
    if (buffer[start].isEstimate) {
      buffer[start].isEstimate    = false;
      buffer[start].data          = jogDataX[0];
    }
    if (buffer[end-1].isEstimate) {
      buffer[end-1].isEstimate  = false;
      buffer[end-1].data        = jogDataX[999%600];
    }
    for (int i = start; i < end; i++) {
      if (!buffer[i].isEstimate) {
        estimates[i%1000] = buffer[i].data;
        previousKnown = i;
      }
      else {
        nextKnown = i;
        while (buffer[nextKnown].isEstimate) { nextKnown++;}
        estimateCount++;
        if (priorityLevels[i] <= 0) System.out.println("Estimated a priority point " + i + "  \n" );
        estimates[i%1000] = 1.0*buffer[previousKnown].data + (1.0*(i - previousKnown)) * ((1.0*(buffer[nextKnown].data - buffer[previousKnown].data)) / ((nextKnown - previousKnown)));
      }
    }


    System.out.println(estimateCount + " \n");

    for (int i = 0; i < 5; i++) {
      previousKnown = nextKnown = i * 200;
      for (int j = (i * 200); j < (200 + (i*200)); j++) {
        if (priorityLevels[j%600] == 0) previousKnown = j;
          nextKnown = j+1;
        if (nextKnown < (200 + (i*200))) {
          while (priorityLevels[nextKnown%1000] != 0) nextKnown++;
            double tempAru = ((absol((double)(estimates[j%1000] - jogDataX[j%600])))/((absol((double)(jogDataX[nextKnown%600] - jogDataX[previousKnown%600])))));
            actualDQIAr[i] += tempAru;
        }
      }
    }
    

    System.out.println("estimate DQI \n" );
    for (int j = 0; j < 5; j++)
      System.out.println(estDQIAr[j] + "\n" );
    System.out.println("actual DQI \n" );
    for (int z = 0; z < 5; z++)
      System.out.println(1- (actualDQIAr[z])/200.0 + "\n" );
  }

  int getDataPLevel(int dataIn) {
    int  priority;
    double  diff0, diff1, diff2, diff3;
    double  prevPrevReading, prevReading, currentReading, nextReading, nextNextReading;

    if (dataIn % 200 == 0 || dataIn % 200 == 1
      || dataIn % 200 == 198 || dataIn % 200 == 199)
      return 0;

    prevPrevReading = jogDataX[dataIn-2];
    prevReading     = jogDataX[dataIn-1];
    currentReading  = jogDataX[dataIn];
    nextReading     = jogDataX[(dataIn+1) % 600];
    nextNextReading = jogDataX[(dataIn+2) % 600];

    // Calculate differences
    diff0 = Math.abs(prevReading - prevPrevReading);
    diff1 = Math.abs(currentReading - prevReading);
    diff2 = Math.abs(nextReading - currentReading);
    diff3 = Math.abs(nextNextReading - nextReading);

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
      priority = 0;
    }
    else if (currentReading > prevReading && currentReading >= nextReading) {
      priority = 0;
    }
    //else if (currentReading > prevReading && currentReading >= nextReading) {
    //  priority = 1;
    //}

    // Local min cases
    else if (currentReading < prevReading && currentReading < nextReading) {
      priority = 0;
    }
    else if (currentReading < prevReading && currentReading <= nextReading) {
      priority = 0;
    }
    //else if (currentReading < prevReading && currentReading <= nextReading) {
    //  priority = 1;
    //}

    // Inflection point cases
    else if (diff1 < diff0 && diff2 < diff3) {
      priority = 1;
    }
    else if (diff1 > diff0 && diff2 > diff3) {
      priority = 1;
    }

    // Large change in slope cases
    else if (diff1 < diff0 / 2 && diff1 < diff2 / 2) {
      priority = 2;
    }
    else if (diff1 > 2* diff0 && diff1 > 2 * diff2) {
      priority = 2;
    }

    // All other cases
    else {
      priority = 3;
    }

    // Done
    return priority;

  }

double[] jogDataX = {
  966 , 
964 , 
964 , 
970 , 
970 , 
966 , 
968 , 
966 , 
966 , 
963 , 
964 , 
958 , 
958 , 
961 , 
958 , 
953 , 
953 , 
948 , 
946 , 
941 , 
941 , 
936 , 
936 , 
940 , 
936 , 
940 , 
940 , 
941 , 
941 , 
943 , 
941 , 
943 , 
940 , 
944 , 
944 , 
949 , 
948 , 
958 , 
958 , 
963 , 
963 , 
968 , 
968 , 
974 , 
973 , 
981 , 
983 , 
991 , 
991 , 
1005 , 
1005 , 
1013 , 
1014 , 
1010 , 
1008 , 
981 , 
979 , 
955 , 
955 , 
943 , 
943 , 
944 , 
943 , 
949 , 
949 , 
955 , 
953 , 
951 , 
951 , 
946 , 
946 , 
940 , 
940 , 
921 , 
921 , 
891 , 
889 , 
911 , 
914 , 
1010 , 
1013 , 
1036 , 
1031 , 
1003 , 
1005 , 
1001 , 
1001 , 
994 , 
993 , 
998 , 
998 , 
1006 , 
1006 , 
1035 , 
1036 , 
1070 , 
1071 , 
1001 , 
971 , 
1265 , 
1321 , 
1033 , 
1301 , 
818 , 
803 , 
621 , 
618 , 
723 , 
729 , 
916 , 
923 , 
1026 , 
1029 , 
1061 , 
1059 , 
1020 , 
1018 , 
981 , 
979 , 
968 , 
970 , 
979 , 
981 , 
996 , 
996 , 
1006 , 
1006 , 
1014 , 
1013 , 
1021 , 
1021 , 
1033 , 
1033 , 
1051 , 
1051 , 
1083 , 
1085 , 
1138 , 
1140 , 
1195 , 
1231 , 
1130 , 
1113 , 
951 , 
981 , 
1179 , 
1144 , 
1104 , 
1106 , 
1115 , 
1108 , 
1065 , 
1063 , 
1001 , 
1000 , 
953 , 
951 , 
921 , 
919 , 
901 , 
901 , 
895 , 
896 , 
895 , 
895 , 
901 , 
899 , 
908 , 
906 , 
918 , 
919 , 
928 , 
928 , 
940 , 
941 , 
949 , 
949 , 
958 , 
958 , 
963 , 
961 , 
966 , 
966 , 
971 , 
966 , 
970 , 
970 , 
974 , 
974 , 
983 , 
983 , 
991 , 
991 , 
1001 , 
1001 , 
1003 , 
1005 , 
1001 , 
1003 , 
1001 , 
1000 , 
1005 , 
1003 , 
1006 , 
1003 , 
1006 , 
1005 , 
1001 , 
1003 , 
1000 , 
1000 , 
996 , 
994 , 
996 , 
993 , 
996 , 
996 , 
993 , 
993 , 
991 , 
993 , 
991 , 
991 , 
989 , 
991 , 
994 , 
994 , 
1001 , 
1001 , 
1008 , 
1008 , 
1013 , 
1013 , 
1020 , 
1020 , 
1023 , 
1023 , 
1029 , 
1028 , 
1040 , 
1040 , 
1050 , 
1048 , 
1056 , 
1056 , 
1053 , 
1055 , 
1048 , 
1048 , 
1036 , 
1036 , 
1028 , 
1028 , 
1025 , 
1028 , 
1029 , 
1028 , 
1014 , 
1013 , 
985 , 
985 , 
966 , 
968 , 
966 , 
966 , 
970 , 
966 , 
971 , 
968 , 
974 , 
973 , 
978 , 
976 , 
991 , 
991 , 
1005 , 
1006 , 
1021 , 
1021 , 
1014 , 
1020 , 
1003 , 
1001 , 
933 , 
933 , 
1036 , 
1038 , 
928 , 
951 , 
1018 , 
1020 , 
1041 , 
1041 , 
1050 , 
1051 , 
1056 , 
1055 , 
1043 , 
1041 , 
1028 , 
1026 , 
1014 , 
1014 , 
1005 , 
1006 , 
1003 , 
1003 , 
1006 , 
1006 , 
1011 , 
1010 , 
1001 , 
1001 , 
989 , 
989 , 
970 , 
970 , 
956 , 
956 , 
959 , 
959 , 
971 , 
973 , 
986 , 
986 , 
1001 , 
1003 , 
1020 , 
1020 , 
1036 , 
1036 , 
1040 , 
1036 , 
1031 , 
1031 , 
1023 , 
1023 , 
1016 , 
1016 , 
1013 , 
1013 , 
1010 , 
1011 , 
1008 , 
1008 , 
1010 , 
1008 , 
1016 , 
1014 , 
1020 , 
1020 , 
1025 , 
1025 , 
1026 , 
1028 , 
1031 , 
1029 , 
1031 , 
1028 , 
1033 , 
1031 , 
1036 , 
1036 , 
1041 , 
1041 , 
1044 , 
1043 , 
1038 , 
1040 , 
1031 , 
1031 , 
1020 , 
1020 , 
1006 , 
1006 , 
996 , 
996 , 
989 , 
991 , 
994 , 
991 , 
996 , 
994 , 
998 , 
993 , 
994 , 
993 , 
991 , 
991 , 
989 , 
989 , 
991 , 
991 , 
994 , 
994 , 
993 , 
993 , 
996 , 
994 , 
989 , 
991 , 
988 , 
986 , 
970 , 
970 , 
963 , 
963 , 
964 , 
966 , 
970 , 
970 , 
978 , 
978 , 
983 , 
983 , 
986 , 
988 , 
1001 , 
1001 , 
1008 , 
1006 , 
998 , 
998 , 
941 , 
938 , 
853 , 
850 , 
881 , 
886 , 
994 , 
1000 , 
1080 , 
1081 , 
1089 , 
1080 , 
1046 , 
1046 , 
1029 , 
1029 , 
1023 , 
1025 , 
1021 , 
1020 , 
1028 , 
1028 , 
1033 , 
1031 , 
1036 , 
1036 , 
1055 , 
1070 , 
1051 , 
1001 , 
1153 , 
1263 , 
974 , 
1218 , 
804 , 
788 , 
733 , 
734 , 
883 , 
886 , 
934 , 
936 , 
951 , 
951 , 
961 , 
961 , 
955 , 
955 , 
959 , 
955 , 
953 , 
955 , 
961 , 
961 , 
971 , 
970 , 
976 , 
976 , 
979 , 
979 , 
983 , 
981 , 
978 , 
978 , 
981 , 
981 , 
989 , 
991 , 
996 , 
998 , 
1008 , 
1008 , 
1021 , 
1021 , 
1026 , 
1026 , 
1013 , 
1013 , 
983 , 
981 , 
951 , 
951 , 
934 , 
933 , 
938 , 
940 , 
953 , 
953 , 
959 , 
959 , 
961 , 
959 , 
955 , 
956 , 
953 , 
953 , 
956 , 
958 , 
963 , 
963 , 
970 , 
970 , 
973 , 
973 , 
979 , 
979 , 
985 , 
983 , 
988 , 
988 , 
983 , 
983 , 
981 , 
983 , 
973 , 
973 , 
966 , 
966 , 
959 , 
959 , 
955 , 
956 , 
953 , 
953 , 
949 , 
949 , 
953 , 
953 , 
961 , 
961 , 
971 , 
971 , 
976 , 
976 , 
973 , 
976 , 
978 , 
976 , 
979 , 
978 , 
981 , 
981 , 
983 , 
981 , 
978 , 
978 , 
971 , 
974 , 
985 , 
986 , 
993 , 
994 , 
1000 , 
1000 , 
1006 , 
1006 , 
1018 , 
1016 , 
1031 , 
1033 , 
1051 , 
1053 , 
1081 , 
1083 , 
1128 , 
1131 , 
1174 , 
1195 , 
1063 , 
1050 , 
959 , 
1036 , 
1083 , 
1080 , 
1123 , 
1125 , 
1141 , 
1135 , 
1083 , 
1080 , 
1005 , 
1003 , 
948 , 
948 , 
919 , 
919 , 
899 , 
899 , 
893 , 
893 , 
889 , 
891 , 
898 , 
898 , 
904 , 
904 , 
916 , 
916 , 
926 , 
926 , 
941 , 
943 , 
966 , 
968 , 
983 , 
983 , 
974 , 
974 , 
966 , 
966 , 
961 , 
961 , 
956 , 
956 , 
961 , 
961 
}; }


/*double[] jogDataX = {2523, 2515, 2055, 2267, 2379, 2183, 2003,
                                    1891, 2143, 2223, 2347, 2143, 1831, 2035,
                                    2171, 2395, 2203, 2307, 2259, 2335, 2371,
                                    2427, 2303, 2363, 2291, 2115, 2075, 2239,
                                    2299, 2299, 2219, 2479, 2531, 2175, 1979,
                                    2051, 2155, 2175, 1431, 2083, 2371, 2563,
                                    2635, 2267, 1911, 1951, 2163, 2267, 1891,
                                    1791, 2219, 2375, 2447, 2415, 2199, 2003,
                                    2091, 2143, 2171, 1919, 2223, 2295, 2391,
                                    2451, 2359, 1919, 2147, 2279, 2315, 1867,
                                    2147, 2435, 2547, 2523, 1951, 2067, 2247,
                                    2315, 2103, 2131, 2311, 2343, 2447, 2475,
                                    2519, 2227, 1823, 2139, 2171, 2315, 2007,
                                    1807, 2307, 2419, 2527, 2007, 1823, 2231,
                                    2459, 1903, 1451, 2079, 2435, 2363, 2407,
                                    2339, 2475, 2011, 2007, 1763, 1807, 2067,
                                    2259, 2227, 2227, 1971, 1467, 1527, 2219,
                                    2283, 1927, 2475, 2231, 2327, 1695, 1563,
                                    2275, 2863, 2335, 2059, 1915, 2123, 1859,
                                    2231, 1883, 1999, 2195, 2415, 2507, 2547,
                                    1919, 1779, 2139, 2195, 2291, 2331, 2048,
                                    1603, 2095, 2667, 2731, 2459, 2159, 2111,
                                    2031, 2235, 2347, 1871, 1559, 1851, 2631,
                                    2635, 2619, 2335, 2111, 2175, 2179, 2111,
                                    2103, 2239, 1791, 1747, 2163, 2563, 2587,
                                    2575, 1963, 1903, 2007, 2035, 2191, 2311,
                                    1823, 2259, 2643, 2771, 2435, 2219, 2251,
                                    2051, 2239, 1991, 1939, 1999, 2343, 2571,
                                    2583, 2367, 2183, 2011, 2151, 2295, 2251,
                                    2027, 2455, 2711, 2631, 2499, 2323, 1803,
                                    1915, 2291, 2247, 2307, 2379, 2355, 1967,
                                    1923, 2347, 2495, 2699, 2503, 2387, 2571,
                                    2259, 2103, 2259, 2063, 2135, 2211, 2235,
                                    2735, 2419, 2227, 2123, 2099, 2255, 2387,
                                    2287, 2243, 2087, 1527, 2435, 2763, 2275,
                                    1947, 1963, 1927, 2219, 2303, 1835, 2346,
                                    2779, 2623, 2127, 1623, 1971, 2339, 2139,
                                    2179, 2415, 2675, 2587, 2219, 2011, 1991,
                                    1927, 1955, 2267, 2279, 2243, 1915, 2831,
                                    2667, 2383, 2083, 1867, 2175, 2219, 2279,
                                    2295, 2067, 1631, 1903, 2427, 2763, 2675,
                                    2411, 2351, 2303, 2287, 2259, 2263, 2099,
                                    2183, 2579, 2755, 2603, 2491, 2327, 2339,
                                    2435, 2463, 2283, 2079, 2071, 2331, 2415,
                                    2479, 2551, 2439, 2527, 2383, 2251, 2235,
                                    2291, 2327, 2175, 2075, 2259, 2399, 2451,
                                    2511, 2599, 2495, 1711, 1495, 2087, 2051,
                                    2083, 1707, 1855, 2163, 2363, 2387, 2443,
                                    1967, 1423, 1959, 2367, 2243, 2223, 1787,
                                    1091, 1907, 2263, 2507, 2519, 2759, 1059,
                                    1319, 2531, 2603, 2351, 2019, 1507, 1971,
                                    2503, 1795, 1479, 1919, 2399, 1995, 1883,
                                    1635, 1671, 2303, 2543, 2595, 2471, 1715,
                                    1075, 1302, 1867, 1795, 1695, 1763, 1550,
                                    2323, 2343, 2287, 1335, 1935, 2179, 1911,
                                    1499, 1807, 2011, 2619, 2675, 2635, 2003,
                                    1423, 1871, 2159, 1975, 1627, 1971, 2423,
                                    2603, 2515, 1507, 1823, 1907, 2071, 2115,
                                    2075, 1331, 1555, 2083, 2671, 2331, 2175,
                                    2343, 2115, 1278, 1891, 2391, 2635, 2603,
                                    2471, 1699, 1351, 2251, 2371, 2299, 2351,
                                    2311, 2015, 1983, 2371, 2307, 1482, 2199,
                                    2679, 2583, 1967, 1631, 1719, 2099, 2187,
                                    2007, 1947, 1626, 1771, 2135, 2583, 2667,
                                    2183, 1543, 1511, 1699, 2255, 2151, 1599,
                                    1951, 2483, 2531, 2671, 2567, 1471, 1195,
                                    2407, 2507, 2427, 2015, 1763, 2303, 2519,
                                    2767, 2475, 1463, 1367, 1975, 2319, 2419,
                                    2351, 1167, 1935, 2467, 2603, 2455, 1087,
                                    1635, 2339, 2295, 1919, 1391, 2255, 2419,
                                    2627, 2555, 1803, 1150, 1323, 1915, 2183,
                                    2303, 2391, 1651, 1118, 1671, 2407, 2635,
                                    2615, 1591, 1419, 1611, 2035, 2395, 2031,
                                    1339, 1967, 2307, 2579, 2763, 2199, 1679,
                                    1395, 1855, 2103, 2171, 2199, 1951, 1863,
                                    2383, 2399, 2615, 2651, 1715, 1755, 2007,
                                    2267, 2111, 1419, 1279, 2579, 2435, 2119,
                                    2251, 2119, 1447, 1763, 2631, 2583, 2263,
                                    1959, 1651, 2227, 2207, 1503, 1779, 2343,
                                    2571, 2419, 1919, 1651, 1707, 2083, 2243,
                                    2115, 1979, 1751, 1755, 2063, 2291, 2611,
                                    2611, 1959, 1651, 1687, 2251, 2347, 1199,
                                    1787, 1855, 2411, 2507, 2647, 2515, 2271,
                                    1591, 1559, 1923, 2267, 2407, 1795, 1495,
                                    2355, 2599, 2675, 1591, 1266, 2171, 2131,
                                    2259, 1186, 2171, 2427, 2851, 2831, 2019,
                                    1959, 2235, 2231, 2048, 1691, 2227, 2543,
                                    2651, 2351, 1535, 1639, 2167, 2351, 2087,
                                    1599, 2251, 2455, 2491, 2379, 1727, 2087,
                                    2167, 2151, 2127, 1759, 1631, 2339, 2651,
                                    2607, 2059, 1711, 1731, 2007, 2339, 1671,
                                    1739, 2175, 2483, 2507, 2475, 2343, 2407,
                                    2327, 2123, 2139, 1947, 1775, 2619, 2951,
                                    2231, 1991, 1655, 2059, 2203, 2203, 2307,
                                    1179, 1955, 2327, 2671, 2307, 1631, 1575,
                                    1803, 2139, 2155, 2087, 1703, 1607, 1703,
                                    2359, 2703, 2383, 1831, 1567, 2235, 2119,
                                    2179, 1391, 1635, 2259, 2611, 2663, 2327,
                                    1971, 1707, 1819, 2049, 2015, 1971, 1719,
                                    1499, 2235, 2635, 2551, 2019, 1555, 1091,
                                    1923, 2227, 2447, 2427, 1214, 1895, 2451,
                                    2595, 2095, 1719, 1899, 2443, 1883, 1379,
                                    1811, 2379, 2627, 2455, 1947, 1639, 2147,
                                    2187, 1907, 1603, 1427, 2571, 2591, 1791,
                                    1491, 2191, 2263, 2175, 1022, 2295, 2671,
                                    2699, 2151, 2219, 1987, 1519, 1895, 2243,
                                    2607, 2507, 1699, 2283, 2283, 2343, 2355,
                                    2395, 2351, 2263, 1859, 1859, 2119, 2283,
                                    2451, 2543, 2387, 2263, 2335, 2259, 2203,
                                    2039, 2031, 2163, 2395, 2403, 2095, 1995,
                                    1979, 2431, 2203, 2003, 2123, 2287, 2291,
                                    1635, 2147, 2471, 2695, 2555, 1883, 1995,
                                    2403, 1923, 2571, 2499, 2455, 1871, 1351,
                                    2151, 2267, 2383, 2183, 1403, 1975, 2347,
                                    2575, 2435, 1847, 2023, 2035, 2335, 1547,
                                    1539, 2419, 2643, 2295, 1943, 1851, 2095,
                                    2259, 2419, 1943, 1527, 2227, 2611, 2823,
                                    1915, 1579, 2111, 2239, 2351, 1847, 1554,
                                    1955, 2567, 2783, 2679, 1995, 1663, 1771,
                                    2371, 2443, 1482, 2011, 2699, 2571, 1487,
                                    1843, 2155, 2339, 1447, 1435, 2151, 2311,
                                    2351, 2387, 2311, 2247, 1971, 1795, 2048,
                                    2167, 2395, 2559, 2035, 2011, 2163, 2363,
                                    2531, 2379, 1827, 2275, 2447, 2167, 2027,
                                    1991, 2251, 2559, 2507, 1927, 1983, 1991,
                                    2299, 2383, 2055, 1955, 2679, 2563, 1935,
                                    1887, 1895, 2219, 2267, 2227, 2059, 1555,
                                    2511, 2715, 2451, 1731, 1667, 2131, 2143,
                                    2351, 2343, 1831, 1635, 2519, 2603, 2527,
                                    1923, 1851, 1939, 2143, 2343, 2083, 2203,
                                    2515, 2571, 1823, 1747, 2071, 2099, 2187,
                                    2347, 1859, 1655, 2131, 2363, 1931, 2103,
                                    2167, 2411, 2059, 1959, 2183, 2551, 2611,
                                    1847, 2131, 2351, 2303, 2007, 1991, 2439,
                                    2499, 2519, 1867, 1871, 2339, 2375, 2263,
                                    2143, 1751, 2179, 2355, 2327, 2311, 2287,
                                    2355, 2379, 2291, 2059, 2067, 2467, 2563,
                                    2459, 2167, 2123, 2239, 2535, 2035, 2027,
                                    2135, 2291, 2379, 2167, 2183, 2383, 2555,
                                    2331, 2043, 2183, 2311, 2331, 1895, 2195,
                                    2535, 2667, 2327, 1963, 2067, 2039, 2023,
                                    2147, 2251, 2643, 2603, 1875, 2099, 2319,
                                    2139, 2251, 2715, 2383, 2211, 1995};

                                  } */
