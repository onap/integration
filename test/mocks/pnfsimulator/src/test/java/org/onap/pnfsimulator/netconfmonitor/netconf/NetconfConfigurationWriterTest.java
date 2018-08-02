package org.onap.pnfsimulator.netconfmonitor.netconf;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import org.apache.commons.io.FileUtils;
import org.junit.Rule;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.migrationsupport.rules.EnableRuleMigrationSupport;
import org.junit.rules.TemporaryFolder;

@EnableRuleMigrationSupport
class NetconfConfigurationWriterTest {

    private static final String TEST_CONFIGURATION = "test-configuration";

    @Rule
    public TemporaryFolder temporaryFolder = new TemporaryFolder();

    @Test
    void writeToFile_should_write_sample_config_when_directory_exists() throws IOException {
        File file = temporaryFolder.newFolder("temp");
        NetconfConfigurationWriter configurationWriter = new NetconfConfigurationWriter(file.getPath());

        configurationWriter.writeToFile(TEST_CONFIGURATION);

        File[] files = file.listFiles();
        assertEquals(1, files.length);

        String content = FileUtils.readFileToString(files[0], "UTF-8");
        assertEquals(TEST_CONFIGURATION, content);
    }

    @Test
    void writeToFile_should_not_write_config_when_directory_doesnt_exist() {
        String logFolderPath = "/not/existing/logs";
        NetconfConfigurationWriter configurationWriter = new NetconfConfigurationWriter(logFolderPath);

        configurationWriter.writeToFile(TEST_CONFIGURATION);

        assertFalse(Files.exists(Paths.get(logFolderPath)));
    }
}