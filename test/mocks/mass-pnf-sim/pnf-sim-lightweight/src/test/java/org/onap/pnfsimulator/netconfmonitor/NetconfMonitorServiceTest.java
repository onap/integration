/// *
// * ============LICENSE_START=======================================================
// * PNF-REGISTRATION-HANDLER
// * ================================================================================
// * Copyright (C) 2018 NOKIA Intellectual Property. All rights reserved.
// * ================================================================================
// * Licensed under the Apache License, Version 2.0 (the "License");
// * you may not use this file except in compliance with the License.
// * You may obtain a copy of the License at
// *
// * http://www.apache.org/licenses/LICENSE-2.0
// *
// * Unless required by applicable law or agreed to in writing, software
// * distributed under the License is distributed on an "AS IS" BASIS,
// * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// * See the License for the specific language governing permissions and
// * limitations under the License.
// * ============LICENSE_END=========================================================
// */
//
// package org.onap.pnfsimulator.netconfmonitor;
//
// import static org.mockito.ArgumentMatchers.anyString;
// import static org.mockito.Mockito.any;
// import static org.mockito.Mockito.anyLong;
// import static org.mockito.Mockito.doNothing;
// import static org.mockito.Mockito.times;
// import static org.mockito.Mockito.verify;
// import static org.mockito.Mockito.when;
//
// import com.tailf.jnc.JNCException;
// import java.io.IOException;
// import java.util.Timer;
// import org.junit.jupiter.api.BeforeEach;
// import org.junit.jupiter.api.Test;
// import org.mockito.Mock;
// import org.mockito.MockitoAnnotations;
// import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConfigurationCache;
// import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConfigurationReader;
// import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConfigurationWriter;
//
// class NetconfMonitorServiceTest {
//
// private NetconfMonitorService service;
//
// @Mock
// private Timer timer;
// @Mock
// private NetconfConfigurationReader reader;
// @Mock
// private NetconfConfigurationWriter writer;
// @Mock
// private NetconfConfigurationCache cache;
//
// @BeforeEach
// void setup() {
// MockitoAnnotations.initMocks(this);
// service = new NetconfMonitorService(timer, reader, writer, cache);
// }
//
// @Test
// void startNetconfService() throws IOException, JNCException {
// when(reader.read()).thenReturn("message");
// doNothing().when(writer).writeToFile(anyString());
// doNothing().when(cache).update(anyString());
//
// service.start();
//
// verify(cache, times(1)).update(anyString());
// verify(writer, times(1)).writeToFile(anyString());
// verify(timer, times(1)).scheduleAtFixedRate(any(), anyLong(), anyLong());
// }
// }
