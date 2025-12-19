package com.kafka.learn.kafkastudy.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.autoconfigure.kafka.KafkaProperties;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.integration.channel.PublishSubscribeChannel;
import org.springframework.kafka.annotation.EnableKafka;
import org.springframework.kafka.config.ConcurrentKafkaListenerContainerFactory;
import org.springframework.kafka.core.ConsumerFactory;
import org.springframework.kafka.core.DefaultKafkaConsumerFactory;
import org.springframework.messaging.MessageChannel;
import reactor.kafka.receiver.KafkaReceiver;
import reactor.kafka.receiver.ReceiverOptions;

import java.util.Collections;

@EnableKafka
@Configuration
@ConditionalOnProperty(name = "regular.kafka.autostart", havingValue = "true", matchIfMissing = false)
public class KafkaConsumerConfiguration {
	private static final Logger logger = LoggerFactory.getLogger(KafkaConsumerConfiguration.class);

	@Value("${regular.kafka.autostart:false}")
	private Boolean regularAutoStart;

	@Bean
	public MessageChannel errorChannel() {
		return new PublishSubscribeChannel();
	}

	@Bean(name = "regularKafkaProperties")
	@ConfigurationProperties(prefix="spring.kafka")
	public KafkaProperties kafkaProperties() {
		return new KafkaProperties();
	}

	@Bean("regularKafkaConsumerFactory")
	public ConsumerFactory<String, String> consumerFactory(
			@Qualifier("regularKafkaProperties") KafkaProperties kafkaProperties
	) {
		return new DefaultKafkaConsumerFactory<>(kafkaProperties.getConsumer().buildProperties(null));
	}

	@Bean("regularKafkaListenerContainerFactory")
	public ConcurrentKafkaListenerContainerFactory<String, String> kafkaListenerContainerFactory(
			@Qualifier("regularKafkaConsumerFactory") ConsumerFactory<String, String> consumerFactory
	) {
		ConcurrentKafkaListenerContainerFactory<String, String> factory = new ConcurrentKafkaListenerContainerFactory<>();
		factory.setConsumerFactory(consumerFactory);
		factory.setAutoStartup(regularAutoStart);
		factory.setConcurrency(5);
		factory.setRecordFilterStrategy(record -> record.value().startsWith("test"));
		logger.info("Configured Kafka listener with concurrency=2, autoStartup={}", regularAutoStart);
		return factory;
	}

	@Bean("reactiveReceiver")
	public KafkaReceiver<Integer, String> kafkaReceiver(
			@Qualifier("regularKafkaProperties") KafkaProperties kafkaProperties
	) {
		return KafkaReceiver.create(ReceiverOptions.<Integer, String>create(
				kafkaProperties.getConsumer().buildProperties(null))
				.subscription(Collections.singleton("my-topic")));
	}
}
