package assembler_main.binary_instructions.instruction_types;

/**
 * Created by Andrei-ch on 2016-03-18.
 */
public class RInstruction extends GenericInstruction {

//    R INSTRUCTION FORMAT:
//      B31-26	    B25-21	    B20-16	    B15-11	    B10-6	        B5-0
//      opcode  	register s	register t	register d	shift amount	function
//    EXAMPLE:
//      add $rd, $rs, $rt

    public RInstruction() {
        init();
        setOpCode("000000");
    }

    public RInstruction(String str) {
        init();
        setOpCode("000000");
        setInstruction(str);
    }

    // general instruction field setters

    public void setRD(String str) {
        this.setInstruction(str, 15, 11);
    }

    public void setShamt(String str) {
        this.setInstruction(str, 10, 6);
    }

    public void setFunct(String str) {
        this.setInstruction(str, 5, 0);
    }

    // instructions list
    public void mult() {
        setFunct("011000");
    }

    public void mflo() {
        setFunct("010010");
    }

    public void jr() {
        setFunct("001000");
    }

    public void mfhi() {
        setFunct("010000");
    }

    public void add() {
        setFunct("100000");
    }

    public void sub() {
        setFunct("100010");
    }

    public void and() {
        setFunct("100100");
    }

    public void div() {
        setFunct("011010");
    }

    public void slt() {
        setFunct("101010");
    }

    public void or() {
        setFunct("100101");
    }

    public void nor() {
        setFunct("100111");
    }

    public void xor() {
        setFunct("101000");
    }

    public void sra() {
        setFunct("000011");
    }

    public void srl() {
        setFunct("000010");
    }

    public void sll() {
        setFunct("000000");
    }


}