package br.com.palerique.influenceanalysis.lambda;

import static org.junit.jupiter.api.Assertions.assertTrue;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.events.SQSEvent;
import com.amazonaws.xray.AWSXRay;
import com.amazonaws.xray.AWSXRayRecorderBuilder;
import com.amazonaws.xray.strategy.sampling.NoSamplingStrategy;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.stream.Stream;
import org.junit.jupiter.api.Test;

public class InvokeTest {

    Gson gson = new GsonBuilder()
            .registerTypeAdapter(SQSEvent.class, new SQSEventDeserializer())
            .setPrettyPrinting()
            .create();

    public InvokeTest() {
        AWSXRayRecorderBuilder builder = AWSXRayRecorderBuilder.standard();
        builder.withSamplingStrategy(new NoSamplingStrategy());
        AWSXRay.setGlobalRecorder(builder.build());
    }

    @Test
    void invokeTest() {
        AWSXRay.beginSegment("blank-java-test");
        String path = "src/test/resources/event.json";
        String eventString = loadJsonFile(path);
        SQSEvent event = gson.fromJson(eventString, SQSEvent.class);
        Context context = new TestContext();
        String requestId = context.getAwsRequestId();
        Lambda handler = new Lambda();
        String result = handler.handleRequest(event, context);
        assertTrue(result.contains("numberOfViews"));
        AWSXRay.endSegment();
    }

    private static String loadJsonFile(String path) {
        StringBuilder stringBuilder = new StringBuilder();
        try (Stream<String> stream = Files.lines(Paths.get(path), StandardCharsets.UTF_8)) {
            stream.forEach(stringBuilder::append);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return stringBuilder.toString();
    }
}
