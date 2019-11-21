/*
 * ============LICENSE_START=======================================================
 * PNF-REGISTRATION-HANDLER
 * ================================================================================
 * Copyright (C) 2018 Nokia. All rights reserved.
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
 * ============LICENSE_END=========================================================
 */

package org.onap.pnfsimulator.simulator.scheduler;

import static org.assertj.core.api.AssertionsForClassTypes.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.google.gson.JsonObject;

import java.io.IOException;
import java.net.MalformedURLException;
import java.security.GeneralSecurityException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.onap.pnfsimulator.simulator.client.utils.ssl.SSLAuthenticationHelper;
import org.quartz.JobDataMap;
import org.quartz.JobDetail;
import org.quartz.JobExecutionContext;
import org.quartz.JobKey;
import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.quartz.SimpleTrigger;

class EventSchedulerTest {

    @InjectMocks
    EventScheduler eventScheduler;

    @Mock
    Scheduler quartzScheduler;
    
    @Mock
    SSLAuthenticationHelper sslAuthenticationHelper;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    void shouldTriggerEventWithGivenConfiguration() throws SchedulerException, IOException, GeneralSecurityException {
        //given
        ArgumentCaptor<JobDetail> jobDetailCaptor = ArgumentCaptor.forClass(JobDetail.class);
        ArgumentCaptor<SimpleTrigger> triggerCaptor = ArgumentCaptor.forClass(SimpleTrigger.class);

        String vesUrl = "http://some:80/";
        int repeatInterval = 1;
        int repeatCount = 4;
        String testName = "testName";
        String eventId = "1";
        JsonObject body = new JsonObject();

        //when
        eventScheduler.scheduleEvent(vesUrl, repeatInterval, repeatCount, testName, eventId, body);

        //then
        verify(quartzScheduler).scheduleJob(jobDetailCaptor.capture(), triggerCaptor.capture());
        JobDataMap actualJobDataMap = jobDetailCaptor.getValue().getJobDataMap();
        assertThat(actualJobDataMap.get(EventJob.BODY)).isEqualTo(body);
        assertThat(actualJobDataMap.get(EventJob.TEMPLATE_NAME)).isEqualTo(testName);
        assertThat(actualJobDataMap.get(EventJob.VES_URL)).isEqualTo(vesUrl);

        SimpleTrigger actualTrigger = triggerCaptor.getValue();
        // repeat count adds 1 to given value
        assertThat(actualTrigger.getRepeatCount()).isEqualTo(repeatCount - 1);

        //getRepeatInterval returns interval in ms
        assertThat(actualTrigger.getRepeatInterval()).isEqualTo(repeatInterval * 1000);
    }

    @Test
    void shouldCancelAllEvents() throws SchedulerException {
        //given
        List<JobKey> jobsKeys = Arrays.asList(new JobKey("jobName1"), new JobKey("jobName2"),
            new JobKey("jobName3"), new JobKey("jobName4"));
        List<JobExecutionContext> jobExecutionContexts = createExecutionContextWithKeys(jobsKeys);
        when(quartzScheduler.getCurrentlyExecutingJobs()).thenReturn(jobExecutionContexts);
        when(quartzScheduler.deleteJobs(jobsKeys)).thenReturn(true);

        //when
        boolean isCancelled = eventScheduler.cancelAllEvents();

        //then
        assertThat(isCancelled).isTrue();
    }

    @Test
    void shouldCancelSingleEvent() throws SchedulerException {
        //given
        JobKey jobToRemove = new JobKey("jobName3");
        List<JobKey> jobsKeys = Arrays.asList(new JobKey("jobName1"), new JobKey("jobName2"),
            jobToRemove, new JobKey("jobName4"));
        List<JobExecutionContext> jobExecutionContexts = createExecutionContextWithKeys(jobsKeys);

        when(quartzScheduler.getCurrentlyExecutingJobs()).thenReturn(jobExecutionContexts);
        when(quartzScheduler.deleteJob(jobToRemove)).thenReturn(true);

        //when
        boolean isCancelled = eventScheduler.cancelEvent("jobName3");

        //then
        assertThat(isCancelled).isTrue();
    }

    private List<JobExecutionContext> createExecutionContextWithKeys(List<JobKey> jobsKeys) {
        List<JobExecutionContext> contexts = new ArrayList<>();
        for (JobKey key : jobsKeys) {
            contexts.add(createExecutionContextFromKey(key));
        }
        return contexts;
    }

    private JobExecutionContext createExecutionContextFromKey(JobKey key) {
        JobExecutionContext context = mock(JobExecutionContext.class);
        JobDetail jobDetail = mock(JobDetail.class);
        when(context.getJobDetail()).thenReturn(jobDetail);
        when(jobDetail.getKey()).thenReturn(key);
        return context;
    }


}
