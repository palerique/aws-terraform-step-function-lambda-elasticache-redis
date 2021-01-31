package br.com.palerique.influenceanalysis.layer;

import static br.com.palerique.influenceanalysis.layer.GenericConstants.MISSING_REQUIRED_ENVIRONMENT_VARIABLES;

import java.util.Objects;
import java.util.stream.Stream;
import lombok.extern.log4j.Log4j2;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.params.SetParams;

@Log4j2
public class RedisUtil {

    public static final String ENV_VAR_CACHE_HOST = "CACHE_HOST";
    public static final String ENV_VAR_CACHE_PORT = "CACHE_PORT";
    public static final String ENV_VAR_CACHE_PWD = "CACHE_PWD";

    /**
     * Params with TTL (Time To Live/expiration) set
     */
    public static final SetParams PARAMS = SetParams.setParams().ex(10);

    public static void save(String key, String value) {
        Jedis jedis = getRedisClient();
        jedis.set(key, value, PARAMS);
    }

    private static Jedis getRedisClient() {
        String cacheHost = Objects.requireNonNullElse(
                System.getenv(ENV_VAR_CACHE_HOST),
                "localhost");
        int cachePort = Integer.parseInt(
                Objects.requireNonNullElse(System.getenv(ENV_VAR_CACHE_PORT),
                        "6379"));
        String cachePwd = System.getenv(ENV_VAR_CACHE_PWD);

        if (Stream.of(cachePwd).allMatch(x -> x == null || x.isEmpty())) {
            log.error(MISSING_REQUIRED_ENVIRONMENT_VARIABLES);
            throw new RuntimeException(MISSING_REQUIRED_ENVIRONMENT_VARIABLES);
        }

        Jedis jedis = new Jedis(cacheHost, cachePort);
        jedis.auth(cachePwd);
        return jedis;
    }

    public static String getAndPrint(String key) {
        Jedis jedis = getRedisClient();

        String value = jedis.get(key);
        System.out.println(value);
        return value;
    }
}
