package org.onap.pnfsimulator.netconfmonitor.netconf;

import com.tailf.jnc.JNCException;
import com.tailf.jnc.NetconfSession;
import java.io.IOException;

public class NetconfConfigurationReader {

    private final NetconfSession session;
    private final String netconfModelPath;

    public NetconfConfigurationReader(NetconfSession session, String netconfModelPath) {
        this.session = session;
        this.netconfModelPath = netconfModelPath;
    }

    public String read() throws IOException, JNCException {
        return session.getConfig(netconfModelPath).first().toXMLString();
    }
}
