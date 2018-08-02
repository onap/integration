package org.onap.pnfsimulator.netconfmonitor;

import com.tailf.jnc.JNCException;
import com.tailf.jnc.NetconfSession;
import com.tailf.jnc.SSHConnection;
import com.tailf.jnc.SSHSession;
import java.io.IOException;
import java.util.Map;
import java.util.Timer;
import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConfigurationCache;
import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConfigurationReader;
import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConfigurationWriter;
import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConnectionParams;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class NetconfMonitorServiceConfiguration {

    private static final Logger LOGGER = LoggerFactory.getLogger(NetconfMonitorServiceConfiguration.class);
    private static final Map<String, String> enviroment = System.getenv();

    private static final String LOG_PATH = "/var/log";

    private static final String NETCONF_ADDRESS = "NETCONF_ADDRESS";
    private static final String NETCONF_PORT = "NETCONF_PORT";
    private static final String NETCONF_MODEL = "NETCONF_MODEL";
    private static final String NETCONF_MAIN_CONTAINER = "NETCONF_MAIN_CONTAINER";

    private static final String DEFAULT_NETCONF_ADDRESS = "localhost";
    private static final int DEFAULT_NETCONF_PORT = 830;
    private static final String DEFAULT_NETCONF_MODEL = "pnf-simulator";
    private static final String DEFAULT_NETCONF_MAIN_CONTAINER = "config";

    private static final String DEFAULT_NETCONF_USER = "netconf";
    private static final String DEFAULT_NETCONF_PASSWORD = "netconf";

    @Bean
    public Timer timer() {
        return new Timer("NetconfMonitorServiceTimer");
    }

    @Bean
    public NetconfConfigurationCache configurationCache() {
        return new NetconfConfigurationCache();
    }

    @Bean
    public NetconfConfigurationReader configurationReader() throws IOException, JNCException {
        NetconfConnectionParams params = resolveConnectionParams();
        LOGGER.info("Configuration params are : {}", params);
        NetconfSession session = createNetconfSession(params);
        return new NetconfConfigurationReader(session, buildModelPath());
    }

    NetconfSession createNetconfSession(NetconfConnectionParams params) throws IOException, JNCException {
        SSHConnection sshConnection = new SSHConnection(params.address, params.port);
        sshConnection.authenticateWithPassword(params.user, params.password);
        return new NetconfSession( new SSHSession(sshConnection));
    }

    @Bean
    public NetconfConfigurationWriter netconfConfigurationWriter() {
        return new NetconfConfigurationWriter(LOG_PATH);
    }

    private String buildModelPath() {
        return String.format("/%s:%s",
            enviroment.getOrDefault(NETCONF_MODEL, DEFAULT_NETCONF_MODEL),
            enviroment.getOrDefault(NETCONF_MAIN_CONTAINER, DEFAULT_NETCONF_MAIN_CONTAINER));
    }

    NetconfConnectionParams resolveConnectionParams() {
        return new NetconfConnectionParams(
            enviroment.getOrDefault(NETCONF_ADDRESS, DEFAULT_NETCONF_ADDRESS),
            resolveNetconfPort(),
            DEFAULT_NETCONF_USER,
            DEFAULT_NETCONF_PASSWORD);
    }

    private int resolveNetconfPort() {
        try {
            return Integer.parseInt(enviroment.get(NETCONF_PORT));
        } catch (NumberFormatException e) {
            LOGGER.warn("Invalid netconf port: {}. Default netconf port {} is set.", e.getMessage(),
                DEFAULT_NETCONF_PORT);
            return DEFAULT_NETCONF_PORT;
        }
    }
}
