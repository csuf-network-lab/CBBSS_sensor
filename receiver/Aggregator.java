// java -cp .:\* Aggregator

import java.io.IOException;
import java.util.ArrayList;
import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;
import org.apache.commons.cli.*;
import org.knowm.xchart.*;

public class Aggregator {
  private boolean                  visFlag;
  private ArrayList<Double>        x, y;
  private ArrayList<SensorProfile> profiles;
  private MoteIF                   mote;
  private SwingWrapper<XYChart>    chartWrapper;
  private XYChart                  chart;

  /*****************************************************************************
  * The constructor for the Data Aggregator. Initializes class variables.
  *****************************************************************************/
  public Aggregator(MoteIF m, boolean v) {
    // Initialize variables
    mote     = m;
    profiles = new ArrayList<SensorProfile>(10);
    visFlag  = v;

    // Initialize the XChart variables and display the chart
    if (visFlag) {
      x = new ArrayList<Double>(100);
      y = new ArrayList<Double>(100);
      x.add(0.0);
      y.add(0.0);

      chart        = QuickChart.getChart
                     ("Sensor Data", "Time", "Readings", "key", x, y);
      chartWrapper = new SwingWrapper<XYChart>(chart);

      chartWrapper.displayChart();
    }

    // Register an anonymous listener for DQI messages
    mote.registerListener(new DQIMsg(), new MessageListener() {
      public void messageReceived(int toAddress, Message message) {
        boolean     spFlag;
        DQIMsg      msg;
        FeedbackMsg feedback;
        int         endId, i, msgId, priorityCount, sensorId, startId;
        int[]       values;

        // Cast the message to the correct data type
        msg = (DQIMsg) message;

        // Retrieve the message fields
        sensorId      = msg.get_sensorId();
        msgId         = msg.get_msgId();
        priorityCount = msg.get_priorityCount();
        startId       = msg.get_startId();
        endId         = msg.get_endId();
        values        = msg.get_values();

        // Print out the contents
        System.out.println("DQIMsg received:");
        System.out.println("\tsensorId = " + sensorId);
        System.out.println("\tmsgId = " + msgId);
        System.out.println("\tpriority count = " + priorityCount);
        System.out.println("\tstartId = " + startId);
        System.out.println("\tendId = " + endId);
        System.out.print("\tvalues = [ ");
        for (i = 0; i < values.length; i++) {
          System.out.print(values[i] / 1000.0 + " ");
        }
        System.out.println("]\n");

        // Find the correct sensor profile
        spFlag = false;
        i      = 0;
        for (SensorProfile sp : profiles) {
          if (sp.getSensorId() == sensorId) {
            spFlag = true;
            break;
          }
          i++;
        }
        if (!spFlag) {
          profiles.add(new SensorProfile(sensorId));
        }

        // Add to the sensor profile
        feedback = profiles.get(i).receiveDQIMsg(msg);
        if (feedback != null) {
          sendFeedbackMsg(feedback);
        }
      }
    });

    // Register an anonymous listener for sensor messages
    mote.registerListener(new SensorMsg(), new MessageListener() {
      public void messageReceived(int toAddress, Message message) {
        boolean   spFlag;
        int       i, j, msgId, readings[], sensorId, tag, times[];
        SensorMsg msg;

        // Cast the message to the correct data type
        msg = (SensorMsg) message;

        // Retrieve the message fields
        sensorId = msg.get_sensorId();
        msgId    = msg.get_msgId();
        tag      = msg.get_tag();
        readings = msg.get_readings();
        times    = msg.get_times();

        // Print out the contents
        System.out.println("SensorMsg received:");
        System.out.println("\tsensorId = " + sensorId);
        System.out.println("\tmsgId = " + msgId);
        System.out.println("\ttag = " + tag);
        System.out.print("\treadings = [ ");
        for (i = 0; i < readings.length; i++) {
          System.out.print(readings[i] + " ");
        }
        System.out.println("]");
        System.out.print("\ttimes = [ ");
        for (i = 0; i < times.length; i++) {
          System.out.print(times[i] + " ");
        }
        System.out.println("]\n");

        // Find the correct sensor profile
        spFlag = false;
        i      = 0;
        for (SensorProfile sp : profiles) {
          if (sp.getSensorId() == sensorId) {
            spFlag = true;
            break;
          }
          i++;
        }
        if (!spFlag) {
          profiles.add(new SensorProfile(sensorId));
        }

        // Add the readings to the sensor profile
        for (j = 0; j < readings.length; j++) {
          profiles.get(i).addData(readings[j], times[j], tag == 1);
        }

        // Update the chart
        if (visFlag) {
          for (i = 0; i < readings.length; i++) {
            if (times[i] >= x.size()) {
              for (j = x.size(); j <= times[i]; j++) {
                x.add((double) j);
                y.add(0.0);
              }
            }
            x.set(times[i], (double) times[i]);
            y.set(times[i], (double) readings[i]);
          }
          chart.updateXYSeries("key", x, y, null);
          chartWrapper.repaintChart();
        }
      }
    });
  }

  /*****************************************************************************
  * 
  *****************************************************************************/
  public void sendFeedbackMsg(FeedbackMsg msg) {
    try {
      mote.send(mote.TOS_BCAST_ADDR, msg);
    }
    catch (IOException e) {
      System.out.println(e.getMessage());
    }
  }

  /*****************************************************************************
  * The starting point of the Data Aggregator. Uses the TelosB mote to build a
  * Phoenix source that feeds the mote IF. Passes this IF to the class object.
  *****************************************************************************/
  public static void main(String[] args) throws Exception {
    Aggregator        agg;
    CommandLine       cmd;
    CommandLineParser parser;
    HelpFormatter     formatter;
    MoteIF            mif;
    Options           opts;
    Option            visualize;
    PhoenixSource     phoenix;
    String            source;

    // Add the visualize flag
    opts      = new Options();
    visualize = new Option("v", "visualize", false, "visualize sensor data");
    visualize.setRequired(false);
    opts.addOption(visualize);

    // Parse the command line
    parser    = new DefaultParser();
    formatter = new HelpFormatter();
    try {
      cmd = parser.parse(opts, args);
    }
    catch (ParseException e) {
      System.out.println(e.getMessage());
      formatter.printHelp("Aggregator", opts);
      System.exit(1);
      return;
    }

    // Create the source and pass the IF to the aggregator
    source  = "serial@/dev/ttyUSB0:telosb";
    phoenix = BuildSource.makePhoenix(source, PrintStreamMessenger.err);
    mif     = new MoteIF(phoenix);
    agg     = new Aggregator(mif, cmd.hasOption("visualize"));
  }
}
