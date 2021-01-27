package br.com.palerique.influenceanalysis.lambda;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.SQSEvent;
import com.amazonaws.services.lambda.runtime.events.SQSEvent.SQSMessage;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.util.concurrent.CompletableFuture;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.params.SetParams;
import software.amazon.awssdk.services.lambda.LambdaAsyncClient;
import software.amazon.awssdk.services.lambda.model.GetAccountSettingsRequest;
import software.amazon.awssdk.services.lambda.model.GetAccountSettingsResponse;

public class Lambda implements RequestHandler<SQSEvent, String> {

    public static final String VALUE = "{\n"
            + "    \"numberOfViews\": 2,\n"
            + "    \"totalJiveUsers\": 17,\n"
            + "    \"shareCount\": 0,\n"
            + "    \"commentCount\": 0,\n"
            + "    \"likeCount\": 0,\n"
            + "    \"influenceScore\": 0.058823529411764705\n"
            + "}";
    public static final String KEY = "foo";
    /**
     * Params with TTL (Time To Live/expiration) set
     */
    public static final SetParams PARAMS = SetParams.setParams().ex(10);
    private static final Logger logger = LoggerFactory.getLogger(Lambda.class);
    private static final Gson gson = new GsonBuilder().setPrettyPrinting().create();
    private static final LambdaAsyncClient lambdaClient = LambdaAsyncClient.create();

    public Lambda() {
        CompletableFuture<GetAccountSettingsResponse> accountSettings =
                lambdaClient.getAccountSettings(GetAccountSettingsRequest.builder().build());
        try {
            GetAccountSettingsResponse settings = accountSettings.get();
            logger.info(String.valueOf(settings));
        } catch (Exception e) {
            e.getStackTrace();
        }
    }

    @Override
    public String handleRequest(SQSEvent event, Context context) {
        String response = "";
        // call Lambda API
        logger.info("Getting account settings");
        CompletableFuture<GetAccountSettingsResponse> accountSettings =
                lambdaClient.getAccountSettings(GetAccountSettingsRequest.builder().build());
        // log execution details
        logger.info("ENVIRONMENT VARIABLES: {}", gson.toJson(System.getenv()));
        logger.info("CONTEXT: {}", gson.toJson(context));
        logger.info("EVENT: {}", gson.toJson(event));
        // process event
        for (SQSMessage msg : event.getRecords()) {
            logger.info(msg.getBody());
        }
        // process Lambda API response
        try {
            GetAccountSettingsResponse settings = accountSettings.get();
            response = gson.toJson(settings.accountUsage());
            logger.info("Account usage: {}", response);
        } catch (Exception e) {
            e.getStackTrace();
        }

        //TODO: testing JEDIS redis client:
        Jedis jedis = new Jedis("localhost", 6379);
        jedis.auth("Redis2019!");
        getAndPrint(jedis);
        jedis.set(KEY, VALUE, PARAMS);
        getAndPrint(jedis);
        try {
            Thread.sleep(10 * 1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        getAndPrint(jedis);
        return response;
    }

    private void getAndPrint(Jedis jedis) {
        String value = jedis.get(KEY);
        System.out.println(value);
    }
}
