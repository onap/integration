/*-
 * ============LICENSE_START=======================================================
 *  Copyright (C) 2019 Nordix Foundation.
 * ================================================================================
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 * ============LICENSE_END=========================================================
 */
package org.onap.aaisimulator.utils;

import static org.onap.aaisimulator.utils.Constants.BI_DIRECTIONAL_RELATIONSHIP_LIST_URL;
import static org.onap.aaisimulator.utils.Constants.RELATIONSHIP_LIST_RELATIONSHIP_URL;
import static org.springframework.http.MediaType.APPLICATION_XML;
import java.net.URI;
import java.util.Arrays;
import java.util.Enumeration;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.servlet.http.HttpServletRequest;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.web.util.UriComponentsBuilder;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
public class HttpServiceUtils {

    private static final String START_WITH_FORWARD_SLASH = "(^/.*?)";
    private static final String ALPHANUMERIC = "((?:v+[a-z0-9]*)/)";
    private static final String REGEX = START_WITH_FORWARD_SLASH + ALPHANUMERIC;
    private static final Pattern PATTERN = Pattern.compile(REGEX, Pattern.CASE_INSENSITIVE | Pattern.DOTALL);

    private HttpServiceUtils() {}

    public static URI getBaseUrl(final HttpServletRequest request) {
        final StringBuffer url = request.getRequestURL();
        final String uri = request.getRequestURI();
        return UriComponentsBuilder.fromHttpUrl(url.substring(0, url.indexOf(uri))).path(getBaseUrl(uri)).build()
                .toUri();
    }

    private static String getBaseUrl(final String uri) {
        final Matcher matcher = PATTERN.matcher(uri);
        if (matcher.find()) {
            final StringBuilder builder = new StringBuilder();
            for (int index = 0; index < matcher.groupCount() - 1; index++) {
                builder.append(matcher.group(index));
            }
            return builder.toString();
        }
        return uri;
    }

    public static URI getBaseUrl(final StringBuffer requestUrl, final String requestUri) {
        return UriComponentsBuilder.fromHttpUrl(requestUrl.substring(0, requestUrl.indexOf(requestUri))).build()
                .toUri();
    }

    public static String getBaseServiceInstanceUrl(final HttpServletRequest request, final String relatedLink) {
        return UriComponentsBuilder.fromUri(getBaseUrl(request)).path(relatedLink).toUriString();
    }

    public static HttpHeaders getHeaders(final HttpServletRequest request) {
        return getHeaders(request, APPLICATION_XML);
    }

    public static HttpHeaders getHeaders(final HttpServletRequest request, final MediaType mediaType) {
        final HttpHeaders headers = new HttpHeaders();
        for (final Enumeration<String> enumeration = request.getHeaderNames(); enumeration.hasMoreElements();) {
            final String headerName = enumeration.nextElement();
            headers.add(headerName, request.getHeader(headerName));
        }
        headers.setContentType(mediaType);
        headers.setAccept(Arrays.asList(MediaType.APPLICATION_XML));
        return headers;
    }

    public static String getTargetUrl(final String targetBaseUrl, final String relatedLink) {
        return UriComponentsBuilder.fromUriString(targetBaseUrl).path(relatedLink)
                .path(BI_DIRECTIONAL_RELATIONSHIP_LIST_URL).toUriString();
    }

    public static String getRelationShipListRelatedLink(final String requestUriString) {
        return requestUriString != null ? requestUriString.replaceFirst(RELATIONSHIP_LIST_RELATIONSHIP_URL, "")
                : requestUriString;
    }

    public static String getBiDirectionalRelationShipListRelatedLink(final String requestUriString) {
        return requestUriString != null ? requestUriString.replaceFirst(BI_DIRECTIONAL_RELATIONSHIP_LIST_URL, "")
                : requestUriString;
    }


}
