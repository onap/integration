package org.onap.pnfsimulator;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory;
import java.io.File;

public class ConfigurationProvider {
    static PnfSimConfig conf = null;

    public static PnfSimConfig getConfigInstance() {

        ObjectMapper mapper = new ObjectMapper(new YAMLFactory());
        try {
            File file = new File("./config/config.yml");

            conf = mapper.readValue(file, PnfSimConfig.class);
            System.out.println("Ves URL: " + conf.getUrlves());
            System.out.println("SFTP URL: " + conf.getUrlsftp());
            System.out.println("FTPS URL: " + conf.getUrlftps());
            System.out.println("PNF sim IP: " + conf.getIppnfsim());

        } catch (Exception e) {
            e.printStackTrace();
        }
        return conf;
    }

}
