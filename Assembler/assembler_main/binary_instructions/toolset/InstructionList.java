package assembler_main.binary_instructions.toolset;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by Andrei-ch on 2016-03-19.
 */
public class InstructionList {

    private static Map<String, String> instr = null;
    private static final String R = "R", I = "I", J = "J";

    public static String get(String key){
        if (instr == null)
            init();
        return instr.get(key);
    }

    /**
     * inits the hashmap.
     * NOTE: not optimized -> multiple buckets for same value (values are only R, I, J)
     */
    private static void init() {
        instr = new HashMap<String, String>();
        List<String> Rlist = new ArrayList<String>() {{
            add("mult");
            add("mflo");
            add("jr");
            add("mfhi");
            add("add");
            add("sub");
            add("and");
            add("div");
            add("slt");
            add("or");
            add("nor");
            add("xor");
            add("sra");
            add("srl");
            add("sll");
        }};
        for (String i : Rlist) instr.put(i, R);

        List<String> Ilist = new ArrayList<String>() {{
            add("addi");
            add("slti");
            add("bne");
            add("sw");
            add("beq");
            add("lw");
            add("lb");
            add("sb");
            add("lui");
            add("andi");
            add("ori");
            add("xori");
            add("asrt");
            add("asrti");
            add("halt");
        }};
        for (String i : Ilist) instr.put(i, I);

        List<String> Jlist = new ArrayList<String>() {{
            add("jal");
            add("j");
        }};
        for (String i : Jlist) instr.put(i, J);
    }
}
