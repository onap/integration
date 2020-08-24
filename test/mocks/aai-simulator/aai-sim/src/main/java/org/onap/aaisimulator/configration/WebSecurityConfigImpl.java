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
package org.onap.aaisimulator.configration;

import org.onap.aaisimulator.utils.Constants;
import org.onap.aaisimulator.configuration.SimulatorSecurityConfigurer;
import org.onap.aaisimulator.model.UserCredentials;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
@Configuration
@EnableWebSecurity
public class WebSecurityConfigImpl extends SimulatorSecurityConfigurer {

    @Autowired
    public WebSecurityConfigImpl(final UserCredentials userCredentials) {
        super(userCredentials.getUsers());
    }

    @Override
    protected void configure(final HttpSecurity http) throws Exception {
        http.csrf().disable().authorizeRequests().antMatchers(Constants.BUSINESS_URL + "/**/**").authenticated().and()
                .httpBasic();
    }

}
