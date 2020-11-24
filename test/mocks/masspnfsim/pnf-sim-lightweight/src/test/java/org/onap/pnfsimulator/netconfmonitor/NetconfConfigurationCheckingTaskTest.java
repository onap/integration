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
// import static org.mockito.ArgumentMatchers.any;
// import static org.mockito.Mockito.never;
// import static org.mockito.Mockito.verify;
// import static org.mockito.Mockito.when;
//
// import com.tailf.jnc.JNCException;
// import java.io.IOException;
// import org.junit.jupiter.api.BeforeEach;
// import org.junit.jupiter.api.Test;
// import org.mockito.Mock;
// import org.mockito.MockitoAnnotations;
// import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConfigurationCache;
// import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConfigurationReader;
// import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConfigurationWriter;
//
// class NetconfConfigurationCheckingTaskTest {
//
// private NetconfConfigurationCheckingTask checkingTask;
//
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
// checkingTask = new NetconfConfigurationCheckingTask(reader, writer, cache);
// }
//
// @Test
// void run_should_update_configuration_when_changed() throws IOException, JNCException {
// String configuration = "newConfiguration";
// when(reader.read()).thenReturn(configuration);
// when(cache.getConfiguration()).thenReturn("oldConfiguration");
//
// checkingTask.run();
//
// verify(reader).read();
// verify(cache).getConfiguration();
// verify(writer).writeToFile(configuration);
// verify(cache).update(configuration);
// }
//
// @Test
// void run_should_not_update_configuration_when_same() throws IOException, JNCException {
// String configuration = "configuration";
// when(reader.read()).thenReturn(configuration);
// when(cache.getConfiguration()).thenReturn("configuration");
//
// checkingTask.run();
//
// verify(reader).read();
// verify(cache).getConfiguration();
// verify(writer, never()).writeToFile(configuration);
// verify(cache, never()).update(configuration);
// }
//
// @Test
// void run_should_not_take_any_action_when_failed_to_read_configuration() throws IOException,
/// JNCException {
// when(reader.read()).thenThrow(new IOException());
//
// checkingTask.run();
//
// verify(reader).read();
// verify(cache, never()).getConfiguration();
// verify(writer, never()).writeToFile(any());
// verify(cache, never()).update(any());
// }
// }
