package br.com.palerique.influenceanalysis;

import com.amazonaws.services.lambda.runtime.events.SQSEvent;
import com.amazonaws.services.lambda.runtime.events.SQSEvent.SQSMessage;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonDeserializationContext;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonElement;
import com.google.gson.JsonParseException;
import com.google.gson.reflect.TypeToken;
import java.lang.reflect.Type;
import java.util.ArrayList;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SQSEventDeserializer implements JsonDeserializer<SQSEvent> {

    private static final Logger logger = LoggerFactory.getLogger(InvokeTest.class);
    Gson gson = new GsonBuilder().setPrettyPrinting().create();
    Type sqsMessageArray = new TypeToken<ArrayList<SQSMessage>>() {
    }.getType();

    @Override
    public SQSEvent deserialize(JsonElement eventJson, Type typeOfT, JsonDeserializationContext context)
            throws JsonParseException {
        SQSEvent event = new SQSEvent();
        logger.info("DESERIALIZING TEST EVENT");
        logger.info("EVENT JSON: " + eventJson.toString());
        // Records key is capitalized in test event, but lowercase in type
        JsonArray recordsArray = eventJson.getAsJsonObject().get("Records").getAsJsonArray();
        ArrayList<SQSMessage> records = gson.fromJson(recordsArray, sqsMessageArray);
        event.setRecords(records);
        return event;
    }
}
