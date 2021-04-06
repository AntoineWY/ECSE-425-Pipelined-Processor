package assembler_main;

import assembler_main.binary_instructions.SpecificInstruction;
import assembler_main.binary_instructions.instruction_types.IInstruction;
import assembler_main.binary_instructions.instruction_types.JInstruction;
import assembler_main.binary_instructions.instruction_types.RInstruction;
import assembler_main.binary_instructions.toolset.Tools;

import javax.tools.Tool;
import java.io.FileNotFoundException;
import java.util.*;

/**
 * Created by Andrei-ch on 2016-03-16.
 */
public class Assembler {

    private static List<String> code, original, original_no_labels;
    private static Map<String, Integer> labels;

    /**
     * builds binary assembly from MIPS code
     *
     * @param path_in
     * @param path_out
     */
    public static void assemble(String path_in, String path_out) {
        // assemble
        List<SpecificInstruction> binary = buildBinaryInstructions(path_in);
        // write to file
        //binary.forEach(System.out::println);
        writeBinaryFile(path_out, binary);
    }

    /**
     * builds a list of binary instructions from MIPS code
     *
     * @param path_in
     * @return
     */
    private static List<SpecificInstruction> buildBinaryInstructions(String path_in) {
        original = trimInstructions(Tools.readFile(path_in));
        original_no_labels = Tools.removeSpaces(parseForAndRemoveLabels(original), false);
        code = Tools.removeSpaces(original_no_labels, true);
        return buildInstructions(code);
    }

    /**
     * writes binary code to a file
     *
     * @param path_out
     * @param binary
     */
    private static void writeBinaryFile(String path_out, List<SpecificInstruction> binary) {
        List<String> out = new ArrayList<String>();
        for (int i = 0; i < binary.size(); i++) {
            out.add(binary.get(i).toString());
        }
        Tools.writeToFile(out, path_out);
    }

    /**
     * removes commented parts and empty lines of code if such exist.
     *
     * @param in
     * @return
     */
    private static List<String> trimInstructions(List<String> in) {
        List<String> out = new ArrayList<String>();
        int index;
        for (String s : in) {
            index = s.indexOf('#');
            // remove commented part if comment was found
            if (index >= 0)
                s = s.substring(0, index);
            // add only if any text is left after removing commented part
            if (s.matches(".*\\w.*"))
                out.add(s);
        }
        return out;
    }

    /**
     * removes labels from code and stores these in a separate static list. code without labels is returned
     *
     * @param in
     * @return
     */
    private static List<String> parseForAndRemoveLabels(List<String> in) {
        List<String> out = new ArrayList<String>();
        labels = new HashMap<String, Integer>();
        int line_index = 0;
        for (String str : in) {
            int colon_index = str.indexOf(':');
            if (colon_index > 0) {
                String label = str.substring(0, colon_index);
                if (label.contains(" "))
                    try {
                        throw new Exception("Compilation error at line: " + original.get(line_index));
                    } catch (Exception e) {
                        e.printStackTrace();
                        System.exit(-1);
                    }
                labels.put(label, line_index);
            }
            str = str.substring(colon_index + 1, str.length());
            out.add(str);
            line_index++;
        }
        return out;
    }

    /**
     * builds a list of binary instructions
     *
     * @param code
     * @return
     */
    private static List<SpecificInstruction> buildInstructions(List<String> code) {
        List<SpecificInstruction> out = new ArrayList<SpecificInstruction>();
        int line_index = 0;
        String op, original_op;
        for (String line : code) {
Tools.print(line_index);

            op = line.substring(0, Math.min(5, line.length()));
            original_op = original_no_labels.get(line_index);
            // remove all non alpha characters
            op = op.replaceAll("[^a-zA-Z\\\\s]", "");
Tools.print(original.get(line_index));
            if (original_op.contains(op)) {
                // do nothing
            } else {
                // fix
                int index = original_op.indexOf(op.charAt(0));
                String sub = original_op.substring(index, original_op.length());
                int space_index = sub.indexOf(' ');
                if (space_index == -1)
                    space_index = sub.indexOf('\t');
                space_index = (space_index > 0) ? space_index : op.length();
                op = op.substring(0, space_index);
            }
            try {
                SpecificInstruction instruction = new SpecificInstruction(op);
                String rs, rt, rd, shamt, address, immediate;
                // remove operation from line string
                line = line.substring(op.length(), line.length());
                List<String> parsed = Tools.parseString(line);
                if (parsed.size() <= 0)
                    throw new Exception("Custom exception -> Invalid instruction syntax: Extra parameters.");
                if (instruction.getInstruction() instanceof RInstruction) {
                    if (op.equals("add") ||
                            op.equals("sub") ||
                            op.equals("and") ||
                            op.equals("slt") ||
                            op.equals("or") ||
                            op.equals("nor") ||
                            op.equals("xor")
                            ) {
                        rd = Tools.formatToBinary(Tools.remove$(parsed.get(0)), 5);
                        rs = Tools.formatToBinary(Tools.remove$(parsed.get(1)), 5);
                        rt = Tools.formatToBinary(Tools.remove$(parsed.get(2)), 5);
                        shamt = "00000";
                        if (parsed.size() > 3)
                            throw new Exception("Custom exception -> Invalid instruction syntax.");
                    } else if (op.equals("sra") ||
                            op.equals("srl") ||
                            op.equals("sll")
                            ) {
                        rd = Tools.formatToBinary(Tools.remove$(parsed.get(0)), 5);
                        rs = "00000";
                        rt = Tools.formatToBinary(Tools.remove$(parsed.get(1)), 5);
                        shamt = Tools.formatToBinary(Tools.remove$(parsed.get(2)), 5);
                        if (parsed.size() > 3)
                            throw new Exception("Custom exception -> Invalid instruction syntax.");
                    } else if (op.equals("mult") ||
                            op.equals("div")
                            ) {
                        rd = "00000";
                        rs = Tools.formatToBinary(Tools.remove$(parsed.get(0)), 5);
                        rt = Tools.formatToBinary(Tools.remove$(parsed.get(1)), 5);
                        shamt = "00000";
                        if (parsed.size() > 2)
                            throw new Exception("Custom exception -> Invalid instruction syntax.");
                    } else if (op.equals("mflo") ||
                            op.equals("mfhi")
                            ) {
                        rd = Tools.formatToBinary(Tools.remove$(parsed.get(0)), 5);
                        rs = "00000";
                        rt = "00000";
                        shamt = "00000";
                        if (parsed.size() > 1)
                            throw new Exception("Custom exception -> Invalid instruction syntax.");
                    } else if (op.equals("jr")
                            ) {
                        rs = Tools.formatToBinary(Tools.remove$(parsed.get(0)), 5);
                        rt = "00000";
                        rd = "00000";
                        shamt = "00000";
                        if (parsed.size() > 1)
                            throw new Exception("Custom exception -> Invalid instruction syntax.");
                    } else {
                        throw new Exception("Custom exception -> Invalid instruction syntax.");
                    }
                    (instruction.getInstruction()).setRS(rs);
                    (instruction.getInstruction()).setRT(rt);
                    ((RInstruction) instruction.getInstruction()).setRD(rd);
                    ((RInstruction) instruction.getInstruction()).setShamt(shamt);
                } else if (instruction.getInstruction() instanceof IInstruction) {
                    if (op.equals("addi") ||
                            op.equals("slti") ||
                            op.equals("andi") ||
                            op.equals("xori") ||
                            op.equals("ori")
                            ) {
                        rt = Tools.formatToBinary(Tools.remove$(parsed.get(0)), 5);
                        rs = Tools.formatToBinary(Tools.remove$(parsed.get(1)), 5);
                        immediate = Tools.formatToBinary(Tools.remove$(parsed.get(2)), 16);
                        if (parsed.size() > 3)
                            throw new Exception("Custom exception -> Invalid instruction syntax.");
                    } else if (op.equals("bne") ||
                            op.equals("beq")
                            ) {
                        rt = Tools.formatToBinary(Tools.remove$(parsed.get(1)), 5);
                        rs = Tools.formatToBinary(Tools.remove$(parsed.get(0)), 5);
                        immediate = parsed.get(2);
                        immediate = Tools.formatToBinary(labels.get(immediate) - line_index - 1, 16);
                        if (parsed.size() > 3)
                            throw new Exception("Custom exception -> Invalid instruction syntax.");
                    } else if (op.equals("sw") ||
                            op.equals("lw") ||
                            op.equals("lb") ||
                            op.equals("sb")
                            ) {
                        rt = Tools.formatToBinary(Tools.remove$(parsed.get(0)), 5);
                        immediate = parsed.get(1);
                        String[] split = immediate.split("\\(");
                        rs = Tools.formatToBinary((Tools.remove$(split[1])).replaceAll("\\)", ""), 5);
                        immediate = Tools.formatToBinary(split[0], 16);
                        if (parsed.size() > 2)
                            throw new Exception("Custom exception -> Invalid instruction syntax.");
                    } else if (op.equals("lui")
                            ) {
                        rt = Tools.formatToBinary(Tools.remove$(parsed.get(0)), 5);
                        rs = "00000";
                        immediate = Tools.formatToBinary(Tools.remove$(parsed.get(1)), 16);
                        if (parsed.size() > 2)
                            throw new Exception("Custom exception -> Invalid instruction syntax.");
                    } else if (op.equals("halt")) {
                        rt = "00000";
                        rs = "00000";
                        immediate = Tools.formatToBinary("0", 16);
                        if (parsed.size() > 1)
                            throw new Exception("Custom exception -> Invalid instruction syntax.");
                    } else if (op.equals("asrt")) {
                        rt = Tools.formatToBinary(Tools.remove$(parsed.get(0)), 5);
                        rs = Tools.formatToBinary(Tools.remove$(parsed.get(1)), 5);
                        ;
                        immediate = Tools.formatToBinary("0", 16);
                        if (parsed.size() > 2)
                            throw new Exception("Custom exception -> Invalid instruction syntax.");
                    } else if (op.equals("asrti")) {
                        rt = Tools.formatToBinary(Tools.remove$(parsed.get(0)), 5);
                        rs = "00000";
                        immediate = Tools.formatToBinary(Tools.remove$(parsed.get(1)), 16);
                        if (parsed.size() > 2)
                            throw new Exception("Custom exception -> Invalid instruction syntax.");
                    } else {
                        throw new Exception("Custom exception -> Invalid instruction syntax.");
                    }
                    (instruction.getInstruction()).setRS(rs);
                    (instruction.getInstruction()).setRT(rt);
                    ((IInstruction) instruction.getInstruction()).setImmediate(immediate);
                } else if (instruction.getInstruction() instanceof JInstruction) {
                    int index = (original_no_labels.get(line_index).contains("jal")) ? 3 : 2;
                    address = original_no_labels.get(line_index).substring(index, original_no_labels.get(line_index).length());
                    address = address.replaceAll("\\s+", "");
                    address = Tools.formatToBinary(labels.get(address), 26);
                    ((JInstruction) instruction.getInstruction()).setAddress(address);
                }
                // add instruction to instruction list
                out.add(instruction);
Tools.print(instruction);
            } catch (Exception e) {
                Tools.print("Compilation error at line: " + original.get(line_index));
                e.printStackTrace();
                System.exit(-1);
            }
            line_index++;
        }
        return out;
    }
}
