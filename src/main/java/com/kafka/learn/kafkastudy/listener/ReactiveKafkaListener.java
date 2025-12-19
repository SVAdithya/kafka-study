package com.kafka.learn.kafkastudy.listener;

import com.kafka.learn.kafkastudy.repository.SuccessMessageRepository;
import com.kafka.learn.kafkastudy.repository.dto.SuccessMessage;

import com.kafka.learn.kafkastudy.util.HeaderUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.kafka.receiver.KafkaReceiver;
import reactor.kafka.receiver.ReceiverRecord;

import java.time.ZonedDateTime;
import java.util.UUID;


@Service
@AllArgsConstructor
@ConditionalOnProperty(name = "reactive.kafka.autostart", havingValue = "true", matchIfMissing = false)
public class ReactiveKafkaListener implements CommandLineRunner {
	private static final Logger logger = LoggerFactory.getLogger(ReactiveKafkaListener.class);

	private KafkaReceiver<Integer, String> kafkaReceiver;
	private HeaderUtil headerUtil;

	private SuccessMessageRepository successMessageRepository;

	public void consumeMessages() {
		Flux<ReceiverRecord<Integer, String>> inboundFlux = kafkaReceiver.receive();
		inboundFlux.subscribe(r -> {
			logger.info("Reactive message: {}", r);
			successMessageRepository.save(new SuccessMessage(
					UUID.randomUUID().toString(),
					headerUtil.headersMapToString(r.headers()),
					r.value(), r.offset(),
					ZonedDateTime.now().toString())
			).subscribe();
			r.receiverOffset().acknowledge();
		});
	}

	@Override
	public void run(String... args) {
		consumeMessages();
	}
}


