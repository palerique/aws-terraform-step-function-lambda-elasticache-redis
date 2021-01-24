/*
 * This Java source file was generated by the Gradle 'init' task.
 */
package br.com.palerique.influenceanalysis.layer;

import java.util.List;

class JoinUtils {

    public static String join(List<String> source) {
        StringBuilder result = new StringBuilder();
        for (Object o : source) {
            if (result.length() > 0) {
                result.append(" ");
            }
            result.append(o);
        }

        return result.toString();
    }
}
