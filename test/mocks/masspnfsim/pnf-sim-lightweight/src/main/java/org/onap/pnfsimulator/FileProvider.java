package org.onap.pnfsimulator;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import org.onap.pnfsimulator.simulator.validation.NoRopFilesException;

public class FileProvider {

    public List<String> getFiles() throws NoRopFilesException {

        List<String> files = queryFiles();

        files.sort(Collections.reverseOrder());

        List<String> fileListSorted = new ArrayList<>();
        for (String f : files) {
            fileListSorted.add(f);
        }
        return fileListSorted;
    }

    private static List<String> queryFiles() throws NoRopFilesException {

        File folder = new File("./files/onap/");
        File[] listOfFiles = folder.listFiles();
        if (listOfFiles == null || listOfFiles.length == 0) {
            throw new NoRopFilesException("No ROP files found in specified directory");
        }

        List<String> results = new ArrayList<>();
        for (int i = 0; i < listOfFiles.length; i++) {
            if (listOfFiles[i].isFile()) {
                results.add(listOfFiles[i].getName());
            }
        }

        return results;
    }
}
