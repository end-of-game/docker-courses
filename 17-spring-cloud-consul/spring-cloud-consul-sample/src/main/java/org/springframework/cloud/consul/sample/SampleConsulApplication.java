/*
 * Copyright 2013-2015 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.springframework.cloud.consul.sample;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.cloud.bootstrap.config.PropertySourceBootstrapProperties;
import org.springframework.cloud.client.ServiceInstance;
import org.springframework.cloud.client.discovery.DiscoveryClient;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.client.loadbalancer.LoadBalancerClient;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author Nicolas Muller
 */
@Configuration
@EnableAutoConfiguration
@EnableDiscoveryClient
@RestController
@EnableConfigurationProperties(PropertySourceBootstrapProperties.class)
public class SampleConsulApplication {

    @Autowired
    private LoadBalancerClient loadBalancer;

    @Autowired
    private DiscoveryClient discoveryClient;

    @Autowired
    private Environment env;

    @Value("${spring.application.name:ConsulDemoTreeptik}")
    private String appName;

    @RequestMapping("/me")
    public ServiceInstance me() {
        return discoveryClient.getLocalServiceInstance();
    }

    @RequestMapping("/")
    public ServiceInstance lb() {
        return loadBalancer.choose(appName);
    }

    @RequestMapping("/choose")
    public String choose() {
        return loadBalancer.choose(appName).getUri().toString();
    }

    @RequestMapping("/myenv")
    public String env(@RequestParam("prop") String prop) {
        return prop + " = " + env.getProperty(prop, "undef");
    }

    @Bean
    public DatabaseConfig databaseConfig() {
        return new DatabaseConfig();
    }

    @Value("${foo:undef}")
    private String foo;

    @Value("${foo.baz:undef}")
    private String foobaz;

    @Value("${question:aucune question}")
    private String question;

    @RequestMapping("/question")
    public String question() {
        StringBuilder builder = new StringBuilder();
        builder.append("foo(1)=").append(foo).append("<br/>");
        builder.append("foo(2)=").append(env.getProperty("foo"));
        builder.append("<br/>").append("<br/>");

        builder.append("foo.baz(1)=").append(foobaz).append("<br/>");
        builder.append("foo.baz(2)=").append(env.getProperty("foo.baz"));
        builder.append("<br/>").append("<br/>");

        builder.append("question(1)=").append(question).append("<br/>");
        builder.append("question(2)=").append(env.getProperty("question"));
        builder.append("<br/>").append("<br/>");

        builder.append("database.url=").append(databaseConfig().getUrl()).append("<br/>");
        builder.append("<br/>").append("<br/>");

        return builder.toString();
    }

    @RequestMapping("/instances")
    public List<ServiceInstance> instances() {
        return discoveryClient.getInstances(appName);
    }

    public static void main(String[] args) {
        SpringApplication.run(SampleConsulApplication.class, args);
    }

}
