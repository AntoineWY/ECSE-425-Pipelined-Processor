package assembler_main.binary_instructions.instruction_types;

/**
 * Created by Andrei-ch on 2016-03-18.
 */
public class JInstruction extends GenericInstruction {

//    I INSTRUCTION FORMAT:
//      B31-26	B25-0
//      opcode  target
//    EXAMPLE:
//      j target

    public JInstruction() {
        init();
    }

    public JInstruction(String str) {
        init();
        setInstruction(str);
    }

    public void setAddress(String str) {
        this.setInstruction(str, 25, 0);
    }

    @Override
    public void setRS(String str) {
        // need not replace anything
    }

    @Override
    public void setRT(String str) {
        // need not replace anything
    }

    public void jal() {
        setOpCode("000011");
    }

    public void j() {
        setOpCode("000010");
    }
}