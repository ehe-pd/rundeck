/*
 * Copyright 2016 SimplifyOps, Inc. (http://simplifyops.com)
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

package rundeck.services

import com.dtolabs.rundeck.app.support.ExecutionQuery
import grails.test.hibernate.HibernateSpec
import groovy.mock.interceptor.MockFor

//import grails.test.GrailsUnitTestCase

import org.springframework.context.ApplicationContext
import rundeck.CommandExec
import rundeck.Execution
import rundeck.ScheduledExecution
import rundeck.Workflow
import testhelper.RundeckHibernateSpec

/**
 * $INTERFACE is ...
 * User: greg
 * Date: 8/7/13
 * Time: 3:07 PM
 */
class ExecutionServiceTests extends RundeckHibernateSpec {

    List<Class> getDomainClasses() { [ScheduledExecution, Workflow, CommandExec]}

    private getAppCtxtMock(){
        def mockAppCtxt = new MockFor(ApplicationContext)
        mockAppCtxt.demand.getBeansOfType(1..1){[]}
        return mockAppCtxt.proxyInstance()
    }
    private List createTestExecs() {

        ScheduledExecution se1 = new ScheduledExecution(
                uuid: 'test1',
                jobName: 'red color',
                project: 'Test',
                groupPath: 'some',
                description: 'a job',
                argString: '-a b -c d',
                workflow: new Workflow(keepgoing: true, commands: [new CommandExec([adhocRemoteString: 'test buddy', argString: '-delay 12 -monkey cheese -particle'])]).save(),
        )
        assert null != se1.save()
        ScheduledExecution se2 = new ScheduledExecution(
                uuid: 'test2',
                jobName: 'green and red color',
                project: 'Test',
                groupPath: 'some/where',
                description: 'a job',
                argString: '-a b -c d',
                workflow: new Workflow(keepgoing: true, commands: [new CommandExec([adhocRemoteString: 'test buddy', argString: '-delay 12 -monkey cheese -particle'])]).save(),
        )
        assert null != se2.save()
        ScheduledExecution se3 = new ScheduledExecution(
                uuid: 'test3',
                jobName: 'blue green and red color',
                project: 'Test',
                groupPath: 'some/where/else',
                description: 'a job',
                argString: '-a b -c d',
                workflow: new Workflow(keepgoing: true, commands: [new CommandExec([adhocRemoteString: 'test buddy', argString: '-delay 12 -monkey cheese -particle'])]).save(),
        )
        assert null != se3.save()
        ScheduledExecution fse1 = new ScheduledExecution(
                uuid: 'test4',
                jobName: 'purple',
                project: 'Future',
                groupPath: 'future',
                description: 'a job',
                argString: '-a b -c d',
                crontabString: '01 13 1 1 1 2099',
                workflow: new Workflow(keepgoing: true, commands: [new CommandExec([adhocRemoteString: 'test buddy', argString: '-delay 12 -monkey cheese -particle'])]).save(),
        )
        assert null != fse1.save(failOnError: true)

        Execution e1 = new Execution(
                scheduledExecution: se1,
                project: "Test",
                status: "true",
                dateStarted: new Date(),
                dateCompleted: new Date(),
                user: 'adam',
                workflow: new Workflow(keepgoing: true, commands: [new CommandExec([adhocRemoteString: 'test1 buddy', argString: '-delay 12 -monkey cheese -particle'])]).save()

        )
        assert null != e1.save()

        Execution e2 = new Execution(
                scheduledExecution: se2,
                project: "Test",
                status: "true",
                dateStarted: new Date(),
                dateCompleted: new Date(),
                user: 'bob',
                workflow: new Workflow(keepgoing: true, commands: [new CommandExec([adhocRemoteString: 'test2 buddy', argString: '-delay 12 -monkey cheese -particle'])]).save()

        )
        assert null != e2.save()
        Execution e3 = new Execution(
                scheduledExecution: se3,
                project: "Test",
                status: "true",
                dateStarted: new Date(),
                dateCompleted: new Date(),
                user: 'chuck',
                workflow: new Workflow(keepgoing: true, commands: [new CommandExec([adhocRemoteString: 'test3 buddy', argString: '-delay 12 -monkey cheese -particle'])]).save()

        )
        assert null != e3.save()
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.MINUTE, 120)
        Date futureDate = cal.getTime()
        Execution schExec1 = new Execution(
                scheduledExecution: fse1,
                project: "Future",
                status: "scheduled",
                dateStarted: futureDate,
                dateCompleted: null,
                user: 'luke',
                workflow: new Workflow(keepgoing: true, commands: [new CommandExec([adhocRemoteString: 'test3 buddy', argString: '-delay 12 -monkey cheese -particle'])]).save()

        )
        assert null != schExec1.save()

        [e1, e2, e3, schExec1]
    }

    /**
     * Test jobExecutions empty
     */
    public void testApiJobExecutions_empty() {
        when:
        def svc = new ExecutionService()

        def execs = createTestExecs()

        ScheduledExecution se4 = new ScheduledExecution(
                uuid: 'test5',
                jobName: 'blah',
                project: 'Test',
                groupPath: 'some',
                description: 'a job',
                argString: '-a b -c d',
                workflow: new Workflow(keepgoing: true, commands: [new CommandExec([adhocRemoteString: 'test buddy', argString: '-delay 12 -monkey cheese -particle'])]).save(),
        )
        assert null != se4.save(failOnError: true)
        svc.applicationContext = getAppCtxtMock()
        def result = svc.queryJobExecutions(se4, null)

        then:
        assert 0 == result.total
    }
    /**
     * Test jobExecutions simple
     */
    public void testApiJobExecutions_simple() {
        when:
        def svc = new ExecutionService()

        def execs = createTestExecs()

        ScheduledExecution se=execs[0].scheduledExecution
        assert null != se
        svc.applicationContext = getAppCtxtMock()
        def result = svc.queryJobExecutions(se, null)

        then:
        assert 1 == result.total
    }
    /**
     * Test jobExecutions succeeded
     */
    public void testApiJobExecutions_success() {
        when:
        def svc = new ExecutionService()

        def execs = createTestExecs()

        ScheduledExecution se=execs[0].scheduledExecution
        assert null != se
        svc.applicationContext = getAppCtxtMock()
        def result = svc.queryJobExecutions(se, 'succeeded')

        then:
        assert 1 == result.total
    }
    /**
     * Test jobExecutions failed
     */
    public void testApiJobExecutions_failed() {
        when:
        def svc = new ExecutionService()

        def execs = createTestExecs()
        Execution e1 = new Execution(
                scheduledExecution: execs[0].scheduledExecution,
                project: "Test",
                status: "false",
                dateStarted: new Date(),
                dateCompleted: new Date(),
                user: 'adam',
                workflow: new Workflow(keepgoing: true, commands: [new CommandExec([adhocRemoteString: 'test1 buddy', argString: '-delay 12 -monkey cheese -particle'])]).save()

        )
        assert null != e1.save()
        execs[0].delete()

        ScheduledExecution se=execs[0].scheduledExecution
        assert null != se
        svc.applicationContext = getAppCtxtMock()
        def result = svc.queryJobExecutions(se, 'failed',0,20)

        then:
        assert 1 == result.total
    }
    /**
     * Test jobExecutions failed
     */
    public void testApiJobExecutions_custom() {
        when:
        def svc = new ExecutionService()

        def execs = createTestExecs()
        Execution e1 = new Execution(
                scheduledExecution: execs[0].scheduledExecution,
                project: "Test",
                status: "custom status",
                dateStarted: new Date(),
                dateCompleted: new Date(),
                user: 'adam',
                workflow: new Workflow(keepgoing: true, commands: [new CommandExec([adhocRemoteString: 'test1 buddy', argString: '-delay 12 -monkey cheese -particle'])]).save()

        )
        assert null != e1.save()
        execs[0].delete()

        ScheduledExecution se=execs[0].scheduledExecution
        assert null != se
        svc.applicationContext = getAppCtxtMock()
        def result = svc.queryJobExecutions(se, 'custom status',0,20)

        then:
        assert 1 == result.total
    }
    /**
     * Test groupPath
     */
    public void testExecutionsQueryGroupPath() {
        when:
        def svc = new ExecutionService()

        def execs = createTestExecs()
        svc.applicationContext = getAppCtxtMock()
        def result = svc.queryExecutions(new ExecutionQuery(projFilter: "Test", groupPath: "some"),0,20)

        then:
        assert 3 == result.total
    }

    /**
     * Test groupPath
     */
    public void testApiExecutionsGroupPathSub1() {
        when:
        def svc = new ExecutionService()

        def execs = createTestExecs()
        svc.applicationContext = getAppCtxtMock()
        def result = svc.queryExecutions(new ExecutionQuery(projFilter: "Test", groupPath: "some/where"), 0, 20)

        then:
        assert 2 == result.total
    }/**
     * Test groupPath
     */
    public void testApiExecutionsGroupPathSub2() {
        when:
        def svc = new ExecutionService()

        def execs = createTestExecs()
        svc.applicationContext = getAppCtxtMock()
        def result = svc.queryExecutions(new ExecutionQuery(projFilter: "Test", groupPath: "some/where/else"), 0, 20)

        then:
        assert 1 == result.total
    }
    /**
     * Test excludeGroupPath subpath 3
     */
    public void testApiExecutionsQueryExcludeGroupPathSub3() {
        when:
        def svc = new ExecutionService()

        def execs = createTestExecs()
        svc.applicationContext = getAppCtxtMock()
        def result = svc.queryExecutions(new ExecutionQuery(projFilter: "Test", excludeGroupPath: "some/where/else"), 0, 20)

        then:
        assert 2 == result.total
    }
    /**
     * Test excludeGroupPath subpath 2
     */
    public void testApiExecutionsQueryExcludeGroupPathSub2() {
        when:
        def svc = new ExecutionService()

        def execs = createTestExecs()
        svc.applicationContext = getAppCtxtMock()
        def result = svc.queryExecutions(new ExecutionQuery(projFilter: "Test", excludeGroupPath: "some/where"), 0, 20)

        then:
        assert 1 == result.total
    }
    /**
     * Test excludeGroupPath subpath equal
     */
    public void testApiExecutionsQueryExcludeGroupPathSubEqual() {
        when:
        def svc = new ExecutionService()

        def execs = createTestExecs()
        svc.applicationContext = getAppCtxtMock()
        def result = svc.queryExecutions(new ExecutionQuery(projFilter: "Test", excludeGroupPath: "some"), 0, 20)

        then:
        assert 0 == result.total
    }

    /**
     * Test groupPathExact (top)
     */
    public void testApiExecutionsGroupPathExact() {
        when:
        def svc = new ExecutionService()

        def execs = createTestExecs()
        svc.applicationContext = getAppCtxtMock()
        def result = svc.queryExecutions(new ExecutionQuery(projFilter: "Test", groupPathExact: "some"), 0, 20)

        then:
        assert 1 == result.total
    }

    /**
     * Test groupPathExact (mid)
     */
    public void testApiExecutionsGroupPathExactSub1() {
        when:
        def svc = new ExecutionService()

        def execs = createTestExecs()
        svc.applicationContext = getAppCtxtMock()
        def result = svc.queryExecutions(new ExecutionQuery(projFilter: "Test", groupPathExact: "some/where"), 0, 20)

        then:
        assert 1 == result.total
    }

    /**
     * Test groupPathExact (bot)
     */
    public void testApiExecutionsGroupPathExactSub2() {
        when:
        def svc = new ExecutionService()

        def execs = createTestExecs()
        svc.applicationContext = getAppCtxtMock()
        def result = svc.queryExecutions(new ExecutionQuery(projFilter: "Test", groupPathExact: "some/where/else"), 0, 20)

        then:
        assert 1 == result.total
    }

    /**
     * Test excludeGroupPathExact level1
     */
    public void testApiExecutionsExcludeGroupPathExact1() {
        when:
        def svc = new ExecutionService()

        def execs = createTestExecs()
        svc.applicationContext = getAppCtxtMock()
        def result = svc.queryExecutions(new ExecutionQuery(projFilter: "Test", excludeGroupPathExact: "some"), 0, 20)

        then:
        assert 2 == result.total
    }

    /**
     * Test excludeGroupPathExact level2
     */
    public void testApiExecutionsExcludeGroupPathExact2() {
        when:
        def svc = new ExecutionService()

        def execs = createTestExecs()
        svc.applicationContext = getAppCtxtMock()
        def result = svc.queryExecutions(new ExecutionQuery(projFilter: "Test", excludeGroupPathExact: "some/where"), 0, 20)

        then:
        assert 2 == result.total
    }

    /**
     * Test excludeGroupPathExact level3
     */
    public void testApiExecutionsExcludeGroupPathExact3() {
        when:
        def svc = new ExecutionService()

        def execs = createTestExecs()
        svc.applicationContext = getAppCtxtMock()
        def result = svc.queryExecutions(new ExecutionQuery(projFilter: "Test", excludeGroupPathExact: "some/where/else"), 0, 20)

        then:
        assert 2 == result.total
    }
    /**
     * Test excludeJob wildcard
     */
    public void testApiExecutionsExcludeJob() {
        when:
        def svc = new ExecutionService()

        def execs = createTestExecs()
        svc.applicationContext = getAppCtxtMock()
        def result = svc.queryExecutions(new ExecutionQuery(projFilter: "Test", excludeJobFilter: "%red color"), 0, 20)

        then:
        assert 0 == result.total
    }
    /**
     * Test excludeJob wildcard 2
     */
    public void testApiExecutionsExcludeJob2() {
        when:
        def svc = new ExecutionService()

        def execs = createTestExecs()
        svc.applicationContext = getAppCtxtMock()
        def result = svc.queryExecutions(new ExecutionQuery(projFilter: "Test", excludeJobFilter: "%green and red color"), 0, 20)

        then:
        assert 1 == result.total
    }
    /**
     * Test excludeJob wildcard 3
     */
    public void testApiExecutionsExcludeJob3() {
        when:
        def svc = new ExecutionService()

        def execs = createTestExecs()
        svc.applicationContext = getAppCtxtMock()
        def result = svc.queryExecutions(new ExecutionQuery(projFilter: "Test", excludeJobFilter: "%blue green and red color"), 0, 20)

        then:
        assert 2 == result.total
    }
    /**
     * Test excludeJobExact 1
     */
    public void testApiExecutionsExcludeJobExact1() {
        when:
        def svc = new ExecutionService()

        def execs = createTestExecs()
        svc.applicationContext = getAppCtxtMock()
        def result = svc.queryExecutions(new ExecutionQuery(projFilter: "Test", excludeJobExactFilter: "red color"), 0, 20)

        then:
        assert 2 == result.total
    }
    /**
     * Test excludeJobExact 2
     */
    public void testApiExecutionsExcludeJobExact2() {
        when:
        def svc = new ExecutionService()

        def execs = createTestExecs()
        svc.applicationContext = getAppCtxtMock()
        def result = svc.queryExecutions(new ExecutionQuery(projFilter: "Test", excludeJobExactFilter: "green and red color"), 0, 20)

        then:
        assert 2 == result.total
    }
    /**
     * Test excludeJobExact 3
     */
    public void testApiExecutionsExcludeJobExact3() {
        when:
        def svc = new ExecutionService()

        def execs = createTestExecs()
        svc.applicationContext = getAppCtxtMock()
        def result = svc.queryExecutions(new ExecutionQuery(projFilter: "Test", excludeJobFilter: "blue green and red color"), 0, 20)

        then:
        assert 2 == result.total
    }
    /**
     * Query for scheduled executions
     */
    public void testApiExecutionsGetScheduled() {
        when:
        def svc = new ExecutionService()

        def execs = createTestExecs()
        svc.applicationContext = getAppCtxtMock()
        def result = svc.queryExecutions(new ExecutionQuery(projFilter: "Future", statusFilter: "scheduled"), 0, 20)

        then:
        assert 1 == result.total
    }

}
