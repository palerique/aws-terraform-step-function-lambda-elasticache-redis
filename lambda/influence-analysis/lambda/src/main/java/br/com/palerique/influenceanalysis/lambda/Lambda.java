package br.com.palerique.influenceanalysis.lambda;

import static br.com.palerique.influenceanalysis.layer.RedisUtil.getAndPrint;
import static br.com.palerique.influenceanalysis.layer.RedisUtil.save;
import static br.com.palerique.influenceanalysis.layer.RestApiUtil.doHttpRequest;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.SQSEvent;
import lombok.extern.log4j.Log4j2;

@Log4j2
public class Lambda implements RequestHandler<SQSEvent, String> {

    public static final String KEY = "redis-key";

    //    private static final Gson gson = new GsonBuilder().setPrettyPrinting().create();
    //    private static final LambdaAsyncClient lambdaClient = LambdaAsyncClient.create();

    //    public Lambda() {
    //        CompletableFuture<GetAccountSettingsResponse> accountSettings =
    //                lambdaClient.getAccountSettings(GetAccountSettingsRequest.builder().build());
    //        try {
    //            GetAccountSettingsResponse settings = accountSettings.get();
    //            log.info(String.valueOf(settings));
    //        } catch (Exception e) {
    //            e.getStackTrace();
    //        }
    //    }

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

        log.info("Lambda is returning {}", response);
        return response;
    }
}
