package com.kafka.learn.kafkastudy.listener;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.messaging.Message;
import org.springframework.stereotype.Component;
import org.springframework.kafka.annotation.KafkaListener;

@Component
@ConditionalOnProperty(name = "regular.kafka.autostart", havingValue = "true", matchIfMissing = false)
public class RegularKafkaListener {
    private static final Logger logger = LoggerFactory.getLogger(RegularKafkaListener.class);

    @KafkaListener(
            id = "regularKafkaListener",
            topics = "#{'${kafka.regular.topic}'}",
            containerFactory = "regularKafkaListenerContainerFactory"
    )
    public void consume(Message<String> message) {
        logger.info("Regular message: {}, Regular header: {}", message.getPayload(), message.getHeaders());
    }
}
