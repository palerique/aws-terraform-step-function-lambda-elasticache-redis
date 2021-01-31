package br.com.palerique.influenceanalysis.layer;

import static br.com.palerique.influenceanalysis.layer.GenericConstants.MISSING_REQUIRED_ENVIRONMENT_VARIABLES;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpClient.Version;
import java.net.http.HttpHeaders;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Base64;
import java.util.stream.Stream;
import lombok.extern.log4j.Log4j2;

@Log4j2
public class RestApiUtil {

    public static final String ENV_VAR_SYSTEM_USERNAME = "SYSTEM_USERNAME";
    public static final String ENV_VAR_SYSTEM_PWD = "SYSTEM_PWD";
    public static final String ENV_VAR_REST_API_ADDRESS = "REST_API_ADDRESS";

    public static final String AUTHORIZATION = "Authorization";

    public static String doHttpRequest() throws IOException, InterruptedException {

        String username = System.getenv(ENV_VAR_SYSTEM_USERNAME);
        String pwd = System.getenv(ENV_VAR_SYSTEM_PWD);
        String restApiAddress = System.getenv(ENV_VAR_REST_API_ADDRESS);

        if (Stream.of(username, pwd, restApiAddress).allMatch(x -> x == null || x.isEmpty())) {
            log.error(MISSING_REQUIRED_ENVIRONMENT_VARIABLES);
            throw new RuntimeException(MISSING_REQUIRED_ENVIRONMENT_VARIABLES);
        }

        HttpClient httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(10))
                .build();

        HttpRequest request = HttpRequest.newBuilder()
                .GET()
                .uri(URI.create(restApiAddress))
                .setHeader(AUTHORIZATION, getAuthorization(username, pwd))
                .version(Version.HTTP_2)
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

        // print response headers
        HttpHeaders headers = response.headers();
        headers.map().forEach((k, v) -> System.out.printf("%s:%s%n", k, v));

        // print status code
        System.out.println(response.statusCode());

        // print response body
        System.out.println(response.body());

        return response.body();
    }

    private static String getAuthorization(String username, String pwd) {
        String encoding = Base64.getEncoder()
                .encodeToString((String.format("%s:%s", username, pwd))
                        .getBytes(StandardCharsets.UTF_8));
        return String.format("Basic %s", encoding);
    }

}
