package br.com.palerique.influenceanalysis.lambda;

import static br.com.palerique.influenceanalysis.layer.RedisUtil.getAndPrint;
import static br.com.palerique.influenceanalysis.layer.RedisUtil.save;
import static br.com.palerique.influenceanalysis.layer.RestApiUtil.doHttpRequest;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.SQSEvent;

public class Lambda implements RequestHandler<SQSEvent, String> {

    public static final String KEY = "redis-key";

    @Override
    public String handleRequest(SQSEvent event, Context context) {

        String response = "";
        try {
            String responseFromRestApi = doHttpRequest();
            save(KEY, responseFromRestApi);
            response = getAndPrint(KEY);
        } catch (Exception e) {
            e.getStackTrace();
        }

        System.out.println("Lambda is returning " + response);
        return response;
    }
}
