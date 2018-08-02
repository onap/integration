package org.onap.pnfsimulator.simulator.client;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.MockitoAnnotations.initMocks;

import java.io.IOException;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;

class HttpClientAdapterImplTest {

    private HttpClientAdapter adapter;

    @Mock
    private HttpClient httpClient;
    @Mock
    private HttpResponse httpResponse;

    @BeforeEach
    void setup() {
        initMocks(this);
        adapter = new HttpClientAdapterImpl(httpClient);
    }

    @Test
    void send_should_successfully_send_request_given_valid_url() throws IOException {
        doReturn(httpResponse).when(httpClient).execute(any());

        adapter.send("test-msg", "http://valid-url");

        verify(httpClient).execute(any());
        verify(httpResponse).getStatusLine();
    }

    @Test
    void send_should_not_send_request_given_invalid_url() throws IOException {
        doThrow(new IOException("test")).when(httpClient).execute(any());

        adapter.send("test-msg", "http://invalid-url");

        verify(httpClient).execute(any());
        verify(httpResponse, never()).getStatusLine();
    }
}
