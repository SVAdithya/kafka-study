package com.kafka.learn.kafkastudy.listener;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.MockitoAnnotations;

import static org.junit.jupiter.api.Assertions.*;

class RegularKafkaListenerTest {
    @InjectMocks
    private RegularKafkaListener regularKafkaListener;
    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }
    @Test
    void testListenerInstantiation() {
        assertNotNull(regularKafkaListener, "Listener should be instantiated");
    }
}
