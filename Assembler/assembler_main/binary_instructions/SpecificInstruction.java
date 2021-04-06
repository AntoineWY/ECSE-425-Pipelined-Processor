package assembler_main.binary_instructions;

import assembler_main.binary_instructions.instruction_types.GenericInstruction;
import assembler_main.binary_instructions.instruction_types.IInstruction;
import assembler_main.binary_instructions.instruction_types.JInstruction;
import assembler_main.binary_instructions.instruction_types.RInstruction;
import assembler_main.binary_instructions.toolset.InstructionList;

/**
 * Created by Andrei-ch on 2016-03-19.
 */
public class SpecificInstruction {

    protected GenericInstruction instruction;

    public SpecificInstruction(String instruction_name) throws Exception{
        String type = InstructionList.get(instruction_name);
        if (type == null) {
            throw new Exception("Custom exception -> Invalid instruction type.");
        }
        if (type.equals("R")) {
            instruction = new RInstruction(instruction_name);
        }
        else if (type.equals("I")) {
            instruction = new IInstruction(instruction_name);
        }
        else if (type.equals("J")) {
            instruction = new JInstruction(instruction_name);
        }
    }

    public GenericInstruction getInstruction(){
        return instruction;
    }

    public String toStringSeparated(){
        return instruction.toString();
    }

    public String toString(){
        return instruction.toString();
    }
}
