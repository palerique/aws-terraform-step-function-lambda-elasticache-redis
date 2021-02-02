package br.com.palerique.influenceanalysis.lambda;

import static br.com.palerique.influenceanalysis.layer.RedisUtil.getAndPrint;
import static br.com.palerique.influenceanalysis.layer.RedisUtil.save;
import static br.com.palerique.influenceanalysis.layer.RestApiUtil.doHttpRequest;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.SQSEvent;

public class Lambda implements RequestHandler<SQSEvent, String> {

    public static final String KEY = "redis-key";

    @Override
    public String handleRequest(SQSEvent event, Context context) {
        LambdaLogger logger = context.getLogger();
        String response = "";
        try {
            response = doHttpRequest();
            //            String responseFromRestApi = "{"
            //                    + "  \"numberOfViews\" : 7,"
            //                    + "  \"totalJiveUsers\" : 2,"
            //                    + "  \"shareCount\" : 0,"
            //                    + "  \"commentCount\" : 0,"
            //                    + "  \"likeCount\" : 0,"
            //                    + "  \"influenceScore\" : 1.75"
            //                    + "}";
            logger.log("response from the rest api: " + response);
        } catch (Exception e) {
            logger.log("some exception was thrown when calling http: " + e.getMessage());
            e.printStackTrace();
        }

        try {
            save(KEY, response);
            logger.log("response from REDIS: " + getAndPrint(KEY));
        } catch (Exception e) {
            logger.log("some exception was thrown when reaching REDIS " + e.getMessage());
            e.printStackTrace();
        }

        logger.log("Lambda is returning " + response);
        return response;
    }
}
