package br.com.palerique.influenceanalysis.layer;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.util.Objects;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.params.SetParams;

public class RedisUtil {

    public static final String ENV_VAR_CACHE_HOST = "CACHE_HOST";
    public static final String ENV_VAR_CACHE_PORT = "CACHE_PORT";

    public static final Gson gson = new GsonBuilder().setPrettyPrinting().create();

    /**
     * Params with TTL (Time To Live/expiration) set
     */
    public static final SetParams PARAMS = SetParams.setParams().ex(10);

    public static void save(String key, Object value) {
        Jedis jedis = getRedisClient();
        jedis.set(key, gson.toJson(value), PARAMS);
    }

    private static Jedis getRedisClient() {
        String cacheHost = Objects.requireNonNullElse(
                System.getenv(ENV_VAR_CACHE_HOST),
                "localhost");
        int cachePort = Integer.parseInt(
                Objects.requireNonNullElse(System.getenv(ENV_VAR_CACHE_PORT),
                        "6379"));
        return new Jedis(cacheHost, cachePort);
    }

    public static String getAndPrint(String key) {
        Jedis jedis = getRedisClient();

        String value = jedis.get(key);
        System.out.println(value);
        return value;
    }
}
