package br.com.palerique.influenceanalysis.lambda;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

public class MessageUtilsTest {

    @Test
    public void testGetMessage() {
        assertEquals("Hello      World!", MessageUtils.getMessage());
    }
}
