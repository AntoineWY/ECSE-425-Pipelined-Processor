package assembler_main.binary_instructions.instruction_types;

import java.util.*;

/**
 * Created by Andrei-ch on 2016-03-18.
 */
public class GenericInstruction {

    protected static final int INSTRUCTION_LENGTH = 32;

    // instruction format: [b31 b30 b29 ... b1 b0]
    protected char[] instruction;

    public void init() {
        this.instruction = new char[INSTRUCTION_LENGTH];
        Arrays.fill(this.instruction, '0');
    }

    public void setOpCode(String str) {
        setInstruction(str, 31, 26);
    }

    public void setRS(String str) {
        this.setInstruction(str, 25, 21);
    }

    public void setRT(String str) {
        this.setInstruction(str, 20, 16);
    }

    public char[] getInstruction() {
        return this.instruction;
    }

    public int remap(int i) {
        return INSTRUCTION_LENGTH - 1 - i;
    }

    public void setInstruction(String str, int i, int j) {
        i = remap(i);
        j = remap(j);
        for (int k = i; k <= j; k++) {
            this.instruction[k] = str.charAt(k - i);
        }
    }

    public void setInstruction(String str) {
        java.lang.reflect.Method method;
        try {
            method = this.getClass().getMethod(str);
            method.invoke(this);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public String toStringSeparated() {
        String str = String.valueOf(instruction);
        return str.substring(0,6) + " " + str.substring(6,11) +
                " " + str.substring(11,16) +
                " " + str.substring(16,21) +
                " " + str.substring(21,24) +
                " " + str.substring(24,28) +
                " " + str.substring(28,32);
    }

    public String toString(){
        return String.valueOf(instruction);
    }
}
