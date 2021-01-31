package br.com.palerique.influenceanalysis.lambda;

import com.amazonaws.services.lambda.runtime.LambdaLogger;
import lombok.NoArgsConstructor;
import lombok.extern.log4j.Log4j2;

@Log4j2
@NoArgsConstructor
public class TestLogger implements LambdaLogger {

    public void log(String message) {
        log.info(message);
    }

    public void log(byte[] message) {
        log.info(new String(message));
    }
}

