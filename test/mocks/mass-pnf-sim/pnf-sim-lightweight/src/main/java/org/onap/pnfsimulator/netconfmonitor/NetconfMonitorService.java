/// *
// * ============LICENSE_START=======================================================
// * PNF-REGISTRATION-HANDLER
// * ================================================================================ Copyright (C)
// * 2018 NOKIA Intellectual Property. All rights reserved.
// * ================================================================================ Licensed under
// * the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance
// * with the License. You may obtain a copy of the License at
// *
// * http://www.apache.org/licenses/LICENSE-2.0
// *
// * Unless required by applicable law or agreed to in writing, software distributed under the
/// License
// * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
/// express
// * or implied. See the License for the specific language governing permissions and limitations
/// under
// * the License. ============LICENSE_END=========================================================
// */
//
// package org.onap.pnfsimulator.netconfmonitor;
//
// import com.tailf.jnc.JNCException;
// import java.io.IOException;
// import java.util.Timer;
// import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConfigurationCache;
// import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConfigurationReader;
// import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConfigurationWriter;
// import org.slf4j.Logger;
// import org.slf4j.LoggerFactory;
// import org.springframework.beans.factory.annotation.Autowired;
//
//// @Service
// public class NetconfMonitorService {
// private static final Logger LOGGER = LoggerFactory.getLogger(NetconfMonitorService.class);
// private static final long timePeriod = 1000L;
// private static final long startDelay = 0;
//
// private Timer timer;
// private NetconfConfigurationReader reader;
// private NetconfConfigurationWriter writer;
// private NetconfConfigurationCache cache;
//
// @Autowired
// public NetconfMonitorService(Timer timer, NetconfConfigurationReader reader,
/// NetconfConfigurationWriter writer,
// NetconfConfigurationCache cache) {
// this.timer = timer;
// this.reader = reader;
// this.writer = writer;
// this.cache = cache;
// }
//
// // @PostConstruct
// public void start() {
// setStartConfiguration();
// NetconfConfigurationCheckingTask task = new NetconfConfigurationCheckingTask(reader, writer,
/// cache);
// timer.scheduleAtFixedRate(task, startDelay, timePeriod);
// }
//
// private void setStartConfiguration() {
// try {
// String configuration = reader.read();
// writer.writeToFile(configuration);
// cache.update(configuration);
// } catch (IOException | JNCException e) {
// LOGGER.warn("Error during configuration reading: {}", e.getMessage());
// }
// }
// }
