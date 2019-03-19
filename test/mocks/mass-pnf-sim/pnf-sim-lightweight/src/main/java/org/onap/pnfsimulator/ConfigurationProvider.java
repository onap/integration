package org.onap.pnfsimulator;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory;
import java.io.File;

public class ConfigurationProvider {
    static PnfSimConfig conf = null;

    String IpVes = null;
    String IpSftp = null;
    String IpFtps = null;
    String IpPnfsim = null;

    public static PnfSimConfig getConfigInstance() {

        ObjectMapper mapper = new ObjectMapper(new YAMLFactory());
        try {
            File file = new File("./config/config.yml");

            conf = mapper.readValue(file, PnfSimConfig.class);
            System.out.println("Ves IP: " + conf.getVesip());
            System.out.println("SFTP IP: " + conf.getIpsftp());
            System.out.println("FTPS IP: " + conf.getIpftps());
            System.out.println("FTPS IP: " + conf.getIppnfsim());

        } catch (Exception e) {
            e.printStackTrace();
        }
        return conf;
    }

}
