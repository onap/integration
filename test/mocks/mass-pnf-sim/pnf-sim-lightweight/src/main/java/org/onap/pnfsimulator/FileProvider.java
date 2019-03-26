package org.onap.pnfsimulator;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class FileProvider {

    private FileProvider() {}

    public static List<String> getFiles() {

        List<String> files = queryFiles();

        files.sort(Collections.reverseOrder());

        List<String> fileListSorted = new ArrayList<>();
        for (String f : files) {
            fileListSorted.add(f);
        }
        return fileListSorted;
    }

    private static List<String> queryFiles() {

        File folder = new File("./files/onap/");
        File[] listOfFiles = folder.listFiles();
        List<String> results = new ArrayList<>();

        if (listOfFiles.length == 0) {
            return results;
            // TODO: this should be a thrown exception catched in the Simulator class
        }

        for (int i = 0; i < listOfFiles.length; i++) {
            if (listOfFiles[i].isFile()) {
                results.add(listOfFiles[i].getName());
            }
        }

        return results;
    }
}
