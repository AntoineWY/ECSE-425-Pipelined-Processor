package assembler_main.binary_instructions.toolset;

import java.io.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.regex.PatternSyntaxException;

/**
 * Created by Andrei-ch on 2016-03-20.
 */
public class Tools {

    /**
     * reads text from a file and returns it as a list of strings
     *
     * @param filename
     * @return
     */
    public static List<String> readFile(String filename) {
        BufferedReader br;
        List<String> out = new ArrayList<String>();
        try {
            br = new BufferedReader(new FileReader(filename));
            try {
                String x;
                while ((x = br.readLine()) != null) {
                    // add every line to a list
                    out.add(x);
                }
            } catch (IOException e) {
                e.printStackTrace();
                System.exit(-1);
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            System.exit(-1);
        }
        return out;
    }


    public static String remove$(String str) {
        return str.replace("$", "");
    }

    /**
     * returns a list of substrings from a coma delimited string
     *
     * @param str
     * @return
     */
    public static List<String> parseString(String str) {
        // separate input string into substrings
        String[] vals = null;
        try {
            vals = str.split(",");
        } catch (PatternSyntaxException ex) {
            ex.printStackTrace();
        }
        return Arrays.asList(vals);
    }

    /**
     * returns a string corresponding to an integer in its binary representation.
     * Length of binary string to return can be specified.
     *
     * @param number
     * @param binary_length
     * @return
     */
    public static String formatToBinary(int number, int binary_length) throws Exception {
        String str = "" + number;
        return formatToBinary(str, binary_length);
    }

    /**
     * returns a string corresponding to a string number in its binary representation.
     * Length of binary string to return can be specified.
     *
     * @param str
     * @param binary_length
     * @return
     * @throws Exception
     */
    public static String formatToBinary(String str, int binary_length) throws Exception {
    	int val = Integer.valueOf(str);
    	int high = (int) (Math.pow(2,binary_length) - 1);
    	int low = (int) -Math.pow(2,binary_length);
    	if ((val > high) || (val < low)) throw new Exception("Custom Exception -> Binary format exceeded.");
        str = Integer.toBinaryString(Integer.valueOf(str));
        if (str.length() > binary_length) str = str.substring(str.length() - binary_length);
        str = (new String(new char[binary_length - str.length()]).replace('\0', '0')) + str;
        return str;
    }

    /**
     * returns index of the first non empty character in string
     *
     * @param str
     * @return
     */
    public static int getIndexOfFirstNonEmptyChar(String str) {
        for (int i = 0; i < str.length(); i++) {
            if (str.charAt(i) != ' ' && str.charAt(i) != '\t') {
                return i;
            }
        }
        return -1;
    }

    /**
     * removes spaces from input string.
     * can be used to remove either every single space, or all spaces until the first non-empty character on each line is found.
     * select via boolean input
     *
     * @param in
     * @param all_spaces
     * @return
     */
    public static List<String> removeSpaces(List<String> in, boolean all_spaces) {
        List<String> out = new ArrayList<String>();
        for (String line : in) {
            // remove spaces
            if (all_spaces)
                line = line.replaceAll("\\s+", "");
            else {
                int index = getIndexOfFirstNonEmptyChar(line);
                line = line.substring(index, line.length());
            }
            out.add(line);
        }
        return out;
    }

    /**
     * prints list to screen
     *
     * @param code
     */
    public static void printCode(List<String> code) {
        int index = 0;
        for (String str : code) {
            print(index + ".\t\t" + str);
            index++;
        }
    }

    public static void print(Object o) {
        System.out.println(o);
    }

    public static void writeToFile(List<String> out, String filename) {
        BufferedWriter br;
        try {
            br = new BufferedWriter(new FileWriter(filename));
            for (String str : out) {
                br.write(str);
                br.write("\n");
            }
            br.flush();
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(-1);
        }
    }
}
