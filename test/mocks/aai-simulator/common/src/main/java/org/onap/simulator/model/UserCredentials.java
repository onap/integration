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
package org.onap.aaisimulator.model;

import java.util.ArrayList;
import java.util.List;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;
import org.springframework.util.ObjectUtils;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
@Component
@ConfigurationProperties(prefix = "spring.security")
public class UserCredentials {

    private final List<User> users = new ArrayList<>();

    public List<User> getUsers() {
        return users;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((users == null) ? 0 : users.hashCode());
        return result;
    }

    @Override
    public boolean equals(final Object obj) {

        if (obj instanceof UserCredentials) {
            final UserCredentials other = (UserCredentials) obj;
            return ObjectUtils.nullSafeEquals(users, other.users);
        }

        return false;
    }

    @Override
    public String toString() {
        return "UserCredentials [userCredentials=" + users + "]";
    }

}
