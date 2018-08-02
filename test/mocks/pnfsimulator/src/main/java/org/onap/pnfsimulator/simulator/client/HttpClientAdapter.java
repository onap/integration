package org.onap.pnfsimulator.simulator.client;

public interface HttpClientAdapter {

    void send(String content, String url);
}
