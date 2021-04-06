import assembler_main.Assembler;
import assembler_main.binary_instructions.toolset.Tools;

import java.io.File;
import java.io.FileNotFoundException;

/**
 * Created by Andrei-ch on 2016-03-19.
 */
public class Driver {

    /**
     * run assembler.
     *
     * @param args
     */
    public static void main(String[] args) {
        String read_from;
        String write_to;
	String this_directory;
        boolean testing = false;
        if (args.length < 1) {
            Tools.print("Missing .asm file input. Please add this to command line.");
            System.exit(-1);
        }
        read_from = getPath("Driver.java");
	this_directory = read_from.substring(0, read_from.length() - ("Driver.java").length());
        read_from = this_directory + args[0];
        write_to = "program.txt";
        Assembler.assemble(read_from, write_to);
    }

    public static String getPath(String name) {
        File f = new File(name);
        return f.getAbsolutePath();
    }
}
