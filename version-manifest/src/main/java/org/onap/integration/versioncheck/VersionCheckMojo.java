/*
 * Copyright 2017 Huawei Technologies, Ltd. and others.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.onap.integration.versioncheck;

import java.io.IOException;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import java.util.TreeSet;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVRecord;
import org.apache.maven.model.Dependency;
import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugin.logging.Log;
import org.apache.maven.plugins.annotations.LifecyclePhase;
import org.apache.maven.plugins.annotations.Mojo;
import org.apache.maven.plugins.annotations.Parameter;
import org.apache.maven.project.MavenProject;

@Mojo(name = "version-check", defaultPhase = LifecyclePhase.PROCESS_SOURCES)
public class VersionCheckMojo extends AbstractMojo {

    /**
     * The Maven Project.
     *
     * @since 1.0-alpha-1
     */
    @Parameter(defaultValue = "${project}", required = true, readonly = true)
    protected MavenProject project;

    /**
     * Location of the file.
     */
    @Parameter(property = "manifestUri", required = true)
    private URI manifestUri;

    public void execute() throws MojoExecutionException {
        final Log log = getLog();

        log.info("Checking version manifest " + manifestUri);

        Map<String, String> expectedVersions = new HashMap<>();

        try (InputStreamReader in = new InputStreamReader(manifestUri.toURL().openStream(),
                StandardCharsets.ISO_8859_1)) {
            Iterable<CSVRecord> records = CSVFormat.DEFAULT.withFirstRecordAsHeader().parse(in);
            for (CSVRecord record : records) {
                String groupId = record.get("groupId");
                String artifactId = record.get("artifactId");
                String version = record.get("version");
                log.debug("Expected version: " + groupId + ":" + artifactId + ":" + version);
                expectedVersions.put(groupId + ":" + artifactId, version);
            }
        } catch (MalformedURLException e) {
            log.error(e);
            throw new MojoExecutionException(e.getMessage());
        } catch (IOException e) {
            log.error(e);
            throw new MojoExecutionException(e.getMessage());
        }

        Map<String, String> actualVersions = new HashMap<>();
        MavenProject parent = project.getParent();
        if (parent != null) {
            log.debug("Parent: " + parent);
            actualVersions.put(parent.getGroupId() + ":" + parent.getArtifactId(), parent.getVersion());
        } else {
            log.debug("No parent");
        }

        for (Dependency dep : project.getDependencies()) {
            log.debug("Dependency: " + dep.toString());
            actualVersions.put(dep.getGroupId() + ":" + dep.getArtifactId(), dep.getVersion());
        }

        Set<String> mismatches = new TreeSet<>();
        for (Entry<String, String> expected : expectedVersions.entrySet()) {
            String artifact = expected.getKey();
            String expectedVersion = expectedVersions.get(artifact);
            String actualVersion = actualVersions.get(artifact);
            if (actualVersion != null && !actualVersion.equals(expectedVersion)) {
                mismatches.add(artifact);
            }
        }

        if (mismatches.isEmpty()) {
            log.debug("No version mismatches found");
        } else {
            log.warn("The following dependencies should be updated to match the version manifest:");
            for (String artifact : mismatches) {
                String expectedVersion = expectedVersions.get(artifact);
                String actualVersion = actualVersions.get(artifact);
                if (actualVersion != null && !actualVersion.equals(expectedVersion)) {
                    log.warn("  " + artifact + " " + actualVersion + " -> " + expectedVersion);
                }
            }
        }

    }
}
