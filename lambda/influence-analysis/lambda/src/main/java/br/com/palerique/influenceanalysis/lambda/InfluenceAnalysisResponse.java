package br.com.palerique.influenceanalysis.lambda;

import java.util.Map;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.Value;

@Data
@Value
@Builder
@AllArgsConstructor
public class InfluenceAnalysisResponse {

    InfluenceAnalysis body;
    Map<String, String> headers;
    int statusCode;
    String message;
    Exception exception;
}
