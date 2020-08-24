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

import java.util.Arrays;
import java.util.List;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
public class RequestErrorBuilder {

    private final ServiceException serviceException = new ServiceException();

    public RequestErrorBuilder messageId(final String messageId) {
        this.serviceException.setMessageId(messageId);
        return this;
    }

    public RequestErrorBuilder text(final String text) {
        this.serviceException.setText(text);
        return this;
    }

    public RequestErrorBuilder variables(final List<String> variables) {
        this.serviceException.setVariables(variables);
        return this;
    }

    public RequestErrorBuilder variables(final String... variables) {
        this.serviceException.setVariables(Arrays.asList(variables));
        return this;
    }

    public RequestError build() {
        final RequestError requestError = new RequestError();
        requestError.setServiceException(serviceException);
        return requestError;
    }

}
