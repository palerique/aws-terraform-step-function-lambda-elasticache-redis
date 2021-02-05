package br.com.palerique.influenceanalysis.lambda;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.Value;

@Data
@Value
@Builder
@AllArgsConstructor
public class InfluenceAnalysis {

    int numberOfViews;
    int totalJiveUsers;
    int shareCount;
    int commentCount;
    int likeCount;
    double influenceScore;
}
