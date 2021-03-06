/**
 * This class is automatically generated by mig. DO NOT EDIT THIS FILE.
 * This class implements a Java interface to the 'ACKMsg'
 * message type.
 */

public class ACKMsg extends net.tinyos.message.Message {

    /** The default size of this message type in bytes. */
    public static final int DEFAULT_MESSAGE_SIZE = 6;

    /** The Active Message type associated with this message. */
    public static final int AM_TYPE = 0;

    /** Create a new ACKMsg of size 6. */
    public ACKMsg() {
        super(DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /** Create a new ACKMsg of the given data_length. */
    public ACKMsg(int data_length) {
        super(data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new ACKMsg with the given data_length
     * and base offset.
     */
    public ACKMsg(int data_length, int base_offset) {
        super(data_length, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new ACKMsg using the given byte array
     * as backing store.
     */
    public ACKMsg(byte[] data) {
        super(data);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new ACKMsg using the given byte array
     * as backing store, with the given base offset.
     */
    public ACKMsg(byte[] data, int base_offset) {
        super(data, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new ACKMsg using the given byte array
     * as backing store, with the given base offset and data length.
     */
    public ACKMsg(byte[] data, int base_offset, int data_length) {
        super(data, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new ACKMsg embedded in the given message
     * at the given base offset.
     */
    public ACKMsg(net.tinyos.message.Message msg, int base_offset) {
        super(msg, base_offset, DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new ACKMsg embedded in the given message
     * at the given base offset and length.
     */
    public ACKMsg(net.tinyos.message.Message msg, int base_offset, int data_length) {
        super(msg, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
    /* Return a String representation of this message. Includes the
     * message type name and the non-indexed field values.
     */
    public String toString() {
      String s = "Message <ACKMsg> \n";
      try {
        s += "  [sensorId=0x"+Long.toHexString(get_sensorId())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [msgId=0x"+Long.toHexString(get_msgId())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [msgType=0x"+Long.toHexString(get_msgType())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      return s;
    }

    // Message-type-specific access methods appear below.

    /////////////////////////////////////////////////////////
    // Accessor methods for field: sensorId
    //   Field type: int, unsigned
    //   Offset (bits): 0
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'sensorId' is signed (false).
     */
    public static boolean isSigned_sensorId() {
        return false;
    }

    /**
     * Return whether the field 'sensorId' is an array (false).
     */
    public static boolean isArray_sensorId() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'sensorId'
     */
    public static int offset_sensorId() {
        return (0 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'sensorId'
     */
    public static int offsetBits_sensorId() {
        return 0;
    }

    /**
     * Return the value (as a int) of the field 'sensorId'
     */
    public int get_sensorId() {
        return (int)getUIntBEElement(offsetBits_sensorId(), 16);
    }

    /**
     * Set the value of the field 'sensorId'
     */
    public void set_sensorId(int value) {
        setUIntBEElement(offsetBits_sensorId(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'sensorId'
     */
    public static int size_sensorId() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'sensorId'
     */
    public static int sizeBits_sensorId() {
        return 16;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: msgId
    //   Field type: int, unsigned
    //   Offset (bits): 16
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'msgId' is signed (false).
     */
    public static boolean isSigned_msgId() {
        return false;
    }

    /**
     * Return whether the field 'msgId' is an array (false).
     */
    public static boolean isArray_msgId() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'msgId'
     */
    public static int offset_msgId() {
        return (16 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'msgId'
     */
    public static int offsetBits_msgId() {
        return 16;
    }

    /**
     * Return the value (as a int) of the field 'msgId'
     */
    public int get_msgId() {
        return (int)getUIntBEElement(offsetBits_msgId(), 16);
    }

    /**
     * Set the value of the field 'msgId'
     */
    public void set_msgId(int value) {
        setUIntBEElement(offsetBits_msgId(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'msgId'
     */
    public static int size_msgId() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'msgId'
     */
    public static int sizeBits_msgId() {
        return 16;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: msgType
    //   Field type: int, unsigned
    //   Offset (bits): 32
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'msgType' is signed (false).
     */
    public static boolean isSigned_msgType() {
        return false;
    }

    /**
     * Return whether the field 'msgType' is an array (false).
     */
    public static boolean isArray_msgType() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'msgType'
     */
    public static int offset_msgType() {
        return (32 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'msgType'
     */
    public static int offsetBits_msgType() {
        return 32;
    }

    /**
     * Return the value (as a int) of the field 'msgType'
     */
    public int get_msgType() {
        return (int)getUIntBEElement(offsetBits_msgType(), 16);
    }

    /**
     * Set the value of the field 'msgType'
     */
    public void set_msgType(int value) {
        setUIntBEElement(offsetBits_msgType(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'msgType'
     */
    public static int size_msgType() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'msgType'
     */
    public static int sizeBits_msgType() {
        return 16;
    }

}
