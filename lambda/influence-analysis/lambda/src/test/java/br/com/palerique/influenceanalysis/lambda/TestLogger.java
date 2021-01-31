package br.com.palerique.influenceanalysis.lambda;

import com.amazonaws.services.lambda.runtime.LambdaLogger;
import lombok.NoArgsConstructor;

@NoArgsConstructor
public class TestLogger implements LambdaLogger {

    public void log(String message) {
        System.err.println(message);
    }

    public void log(byte[] message) {
        System.err.println(new String(message));
    }
}

