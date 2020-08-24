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

import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlRootElement;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
@XmlRootElement(name = "serviceException")
@XmlAccessorType(XmlAccessType.FIELD)
public class ServiceException {

    private String messageId;

    private String text;

    private List<String> variables;

    /**
     * @return the messageId
     */
    public String getMessageId() {
        return messageId;
    }

    /**
     * @param messageId the messageId to set
     */
    public void setMessageId(final String messageId) {
        this.messageId = messageId;
    }

    /**
     * @return the text
     */
    public String getText() {
        return text;
    }

    /**
     * @param text the text to set
     */
    public void setText(final String text) {
        this.text = text;
    }

    /**
     * @return the variables
     */
    public List<String> getVariables() {
        return variables;
    }

    /**
     * @param variables the variables to set
     */
    public void setVariables(final List<String> variables) {
        this.variables = variables;
    }

    @Override
    public String toString() {
        return "ServiceException [messageId=" + messageId + ", text=" + text + ", variables=" + variables + "]";
    }

}
