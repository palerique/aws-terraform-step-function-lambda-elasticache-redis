package br.com.palerique.influenceanalysis.lambda;

import static br.com.palerique.influenceanalysis.lambda.MessageUtils.getMessage;
import static br.com.palerique.influenceanalysis.layer.StringUtils.join;
import static br.com.palerique.influenceanalysis.layer.StringUtils.split;

import java.util.List;

public class Lambda {

    public static void main(String[] args) {
        List<String> tokens = split(getMessage());
        String result = join(tokens);
        System.out.println(result);
    }
}
