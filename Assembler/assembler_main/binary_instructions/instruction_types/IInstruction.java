package assembler_main.binary_instructions.instruction_types;

/**
 * Created by Andrei-ch on 2016-03-18.
 */
public class IInstruction extends GenericInstruction {

//    I INSTRUCTION FORMAT:
//      B31-26	    B25-21	    B20-16	        B15-0
//      opcode  	register s	register t      immediate
//    EXAMPLE:
//      addi $rt, $rs, immediate

    public IInstruction() {
        init();
    }

    public IInstruction(String str) {
        init();
        setInstruction(str);
    }

    public void setImmediate(String str) {
        this.setInstruction(str, 15, 0);
    }

    public void addi() {
        setOpCode("001000");
    }

    public void slti() {
        setOpCode("001010");
    }

    public void bne() {
        setOpCode("000101");
    }

    public void sw() {
        setOpCode("101011");
    }

    public void beq() {
        setOpCode("000100");
    }

    public void lw() {
        setOpCode("100011");
    }

    public void lb() {
        setOpCode("100000");
    }

    public void sb() {
        setOpCode("101000");
    }

    public void lui() {
        setOpCode("001111");
    }

    public void andi() {
        setOpCode("001100");
    }

    public void ori() {
        setOpCode("001101");
    }

    public void xori() {
        setOpCode("001110");
    }

    public void asrt() {
        setOpCode("010100");
    }

    public void asrti() {
        setOpCode("010101");
    }

    public void halt() {
        setOpCode("010110");
    }

}