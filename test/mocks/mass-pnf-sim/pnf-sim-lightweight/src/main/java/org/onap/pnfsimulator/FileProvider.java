package org.onap.pnfsimulator;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class FileProvider {

    public static ArrayList<String> getFiles() {

        List<String> files = QueryFiles();

        Collections.sort(files);

        ArrayList<String> fileListSorted = new ArrayList<String>();
        for (String f : files) {
            System.out.println("Next file: " + f);
            fileListSorted.add(f);
        }
        return fileListSorted;
    }

    private static List<String> QueryFiles() {

        File folder = new File("./files/onap/");
        File[] listOfFiles = folder.listFiles();
        ArrayList<String> results = new ArrayList<String>();

        if (listOfFiles.length == 0) {
            return null;
            // TODO: this should be a thrown exception catched in the Simulator class
        }

        for (int i = 0; i < listOfFiles.length; i++) {
            if (listOfFiles[i].isFile()) {
                System.out.println("File: " + listOfFiles[i].getName());
                results.add(listOfFiles[i].getName());
            }
        }

        return results;
    }
}
