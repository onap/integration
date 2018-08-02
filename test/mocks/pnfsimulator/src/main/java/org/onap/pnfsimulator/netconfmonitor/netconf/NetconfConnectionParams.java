package org.onap.pnfsimulator.netconfmonitor.netconf;

public class NetconfConnectionParams {

    public final String address;
    public final int port;
    public final String user;
    public final String password;

    public NetconfConnectionParams(String address, int port, String user, String password) {
        this.address = address;
        this.port = port;
        this.user = user;
        this.password = password;
    }

    @Override
    public String toString() {
        return String.format("NetconfConnectionParams{address=%s, port=%d, user=%s, password=%s}",
            address,
            port,
            user,
            password);
    }
}