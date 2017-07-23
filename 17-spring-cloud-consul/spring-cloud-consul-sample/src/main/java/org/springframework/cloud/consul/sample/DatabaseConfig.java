package org.springframework.cloud.consul.sample;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties
public class DatabaseConfig {

    @Value("${database.url}")
    private String url;

    public String getUrl() {
        return url;
    }
}

