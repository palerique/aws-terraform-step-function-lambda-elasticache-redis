package br.com.palerique.influenceanalysis.lambda;

import static br.com.palerique.influenceanalysis.layer.RedisUtil.getAndPrint;
import static br.com.palerique.influenceanalysis.layer.RedisUtil.save;
import static br.com.palerique.influenceanalysis.layer.RestApiUtil.doHttpRequest;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestStreamHandler;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

public class Lambda implements RequestStreamHandler {

    public static final String KEY = "redis-key";
    public static final String X_CUSTOM_HEADER = "x-custom-header";

    public static final Gson gson = new GsonBuilder().setPrettyPrinting().create();

    @Override
    public void handleRequest(
            InputStream inputStream, OutputStream outputStream, Context context)
            throws IOException {

        LambdaLogger logger = context.getLogger();
        logger.log("Handling the request");

        BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));

        InfluenceAnalysisResponse response;
        try {
            HashMap event = gson.fromJson(reader, HashMap.class);
            logger.log("Event received: " + event);

            InfluenceAnalysis influenceAnalysis = gson.fromJson(doHttpRequest(), InfluenceAnalysis.class);
            logger.log("response from the rest api: " + influenceAnalysis);

            Map<String, String> headers = new HashMap<>();
            headers.put(X_CUSTOM_HEADER, "my custom header value");

            response = InfluenceAnalysisResponse.builder()
                    .message("Some message to return")
                    .body(influenceAnalysis)
                    .headers(headers)
                    .statusCode(200)
                    .build();

            save(KEY, influenceAnalysis);

            logger.log("response from REDIS: " + getAndPrint(KEY));

        } catch (InterruptedException pex) {
            logger.log("some exception was thrown when calling http: " + pex.getMessage());
            response = InfluenceAnalysisResponse.builder()
                    .message("Error")
                    .statusCode(400)
                    .exception(pex)
                    .build();
        }

        String json = gson.toJson(response);
        logger.log("lambda is responding with:\n" + json);
        OutputStreamWriter writer = new OutputStreamWriter(outputStream, StandardCharsets.UTF_8);
        writer.write(json);
        writer.close();
        logger.log("lambda finished");
    }
}
