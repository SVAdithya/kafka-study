package com.kafka.learn.kafkastudy.listener;

import com.kafka.learn.kafkastudy.repository.SuccessMessageRepository;
import com.kafka.learn.kafkastudy.repository.dto.SuccessMessage;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.messaging.Message;
import org.springframework.stereotype.Component;
import org.springframework.kafka.annotation.KafkaListener;

import java.time.ZonedDateTime;
import java.util.UUID;

@Component
@AllArgsConstructor
@ConditionalOnProperty(name = "regular.kafka.autostart", havingValue = "true", matchIfMissing = false)
public class RegularKafkaListener {
    private final SuccessMessageRepository successMessageRepository;

    private static final Logger logger = LoggerFactory.getLogger(RegularKafkaListener.class);

    @KafkaListener(
            id = "regularKafkaListener",
            topics = "#{'${kafka.regular.topic}'}",
            containerFactory = "regularKafkaListenerContainerFactory"
    )
    public void consume(Message<String> message) {
        logger.info("Regular message: {}, Regular header: {}", message.getPayload(), message.getHeaders());
        SuccessMessage successMessage = new SuccessMessage(
                UUID.randomUUID().toString(),
                message.getHeaders().toString(),
                message.getPayload(),
                null, // offset not available in regular listener
                ZonedDateTime.now().toString()
        );

        successMessageRepository.save(successMessage)
                .subscribe(
                        saved -> logger.info("Saved message to DB: {}", saved.id()),
                        error -> logger.error("Error saving to DB: {}", error.getMessage())
                );
    }
}
