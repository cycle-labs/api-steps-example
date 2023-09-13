# Creating Custom Web Reports

When generating web reports, you can now customize the report, using Jasper Reports.
To create a custom report, download [Jaspersoft Studio](https://sourceforge.net/projects/jasperstudio/).
The Jaspersoft Studio version must match the version of the engine included with Cycle (at the time of writing, it is
6.17.0).
A sample report template has been included for you and is included in the Reports folder of your project.
The sample template is BasicCycleReport.jrxml. An excellent resource to get started with Jasper Reports is the 
[JasperReports Library Ultimate Guide](https://community.jaspersoft.com/documentation).

The same schema used for the data store is now available for web reports.  For detailed documentation of that schema,
see the Data Store Reports section of the User Manual.  The schema is documented under the JDBC Data store ERD subsection.
A sample query that would include terminal screenshots and images is as follows.

```sql
SELECT (SELECT name FROM CYCLE_EXECUTION_RESULTS AS HEADER where HEADER.execution_id = CYCLE_TEST_EXECUTION.EXECUTION_ID AND HEADER.parent_node_id IS null) as TITLE,
       (SELECT FILE_URI FROM CYCLE_EXECUTION_RESULTS AS HEADER where HEADER.execution_id = CYCLE_TEST_EXECUTION.EXECUTION_ID AND HEADER.parent_node_id IS null) as FILE_URI,
       CYCLE_EXECUTION_RESULTS.NODE_ID,
       REPLACE( REGEXP_REPLACE( CYCLE_EXECUTION_RESULTS.NODE_ID,'[^\\.]',''),'.',' ') || CYCLE_EXECUTION_RESULTS.NAME AS indent_name,
       CYCLE_EXECUTION_RESULTS.NAME,
       CYCLE_EXECUTION_RESULTS.STATUS,
       FORMATDATETIME(CYCLE_EXECUTION_RESULTS.START_TIME,'HH:mm:ss.SSS') as START_TIME,
       FORMATDATETIME(CYCLE_EXECUTION_RESULTS.END_TIME,'HH:mm:ss.SSS') as END_TIME,
       CYCLE_TERMINAL_SCREENS.SCREEN as SCREEN,
       CYCLE_IMAGE.IMAGE,
       CYCLE_TEST_EXECUTION.EXECUTION_ID,
       TRIM(BOTH '' FROM CYCLE_TEST_EXECUTION.INVOKER) AS APP,
       replace(FORMATDATETIME(CYCLE_TEST_EXECUTION.EXECUTION_START_TS, 'yyyy-MM-dd HH:mm:ssZ'), ' ', '<br/>') as EXECUTION_START_TS
  FROM CYCLE_TEST_EXECUTION
  JOIN CYCLE_EXECUTION_RESULTS 
    ON CYCLE_TEST_EXECUTION.EXECUTION_ID = CYCLE_EXECUTION_RESULTS.EXECUTION_ID 
  LEFT JOIN CYCLE_TERMINAL_SCREENS 
    ON CYCLE_TERMINAL_SCREENS.EXECUTION_ID = CYCLE_EXECUTION_RESULTS.EXECUTION_ID 
   AND CYCLE_TERMINAL_SCREENS.NODE_ID = CYCLE_EXECUTION_RESULTS.NODE_ID 
  LEFT JOIN CYCLE_IMAGE_RESULTS 
    ON CYCLE_IMAGE_RESULTS.EXECUTION_ID = CYCLE_EXECUTION_RESULTS.EXECUTION_ID 
   AND CYCLE_IMAGE_RESULTS.NODE_ID = CYCLE_EXECUTION_RESULTS.NODE_ID 
  LEFT JOIN CYCLE_IMAGE 
    ON CYCLE_IMAGE.ID = CYCLE_IMAGE_RESULTS.SCREENSHOT_IMAGE_ID 
 WHERE CYCLE_TEST_EXECUTION.EXECUTION_ID = $P{execution_id} 
 ORDER BY CYCLE_EXECUTION_RESULTS.NODE_SEQUENCE ASC
```

When a web report is being generated, Cycle will provide Jasper with the JDBC connection and two parameters, execution_id
and SUBREPORT_ROOT.  If you are not using any subreports, the only parameter you'll need to include in your query is `P${execution_id}`.
If you are utilizing a subreport, though Jaspersoft Studio will automatically find the other reports in your workspace, the
embedded Jasper report engine does not, and a full path to the subreport will be required.  Since that's often going to be
not practical as the same Cycle project may be run on a variety of machines, Cycle will pass in a SUBREPORT_ROOT, which is
will be calculated as the parent directory of the main report. So if your subreport name is `DetailReport.jasper`, then the
expression in your main report for the location of the subreport would be `$P{SUBREPORT_ROOT} + "DetailReport.jasper"`.
Note that the SUBREPORT_ROOT will include a trailing slash.  So, for example, if your reports are in a directory with a path
of `C:/Users/Cycle/Reports`, the SUBREPORT_ROOT parameter passed to the main report will be `C:/Users/Cycle/Reports/`.

Once your custom report is ready to use, you will compile your .jrxml file into a .japser file.
The .jasper file must be copied to a directory in your project, such as the Reports directory.  In your
project settings, under the Report Settings category, set the "Web Report Template" setting to "Custom".
Then set the "Custom Web Report Template" setting to path of your .jasper file.  The next test in your project that is configured to produce a web report
will then use your new custom template rather than the standard template.  To revert back to the standard template, simply
set the "Web Report Template" setting to "Default"; you do not need to clear the "Custom Web Report Template" setting.

When running cyclecli, the keys for these settings are:
* LocalReportKey
  * This setting controls whether the standard (default) template or a custom template should be used when generating web reports.
  * Valid values are "Custom" or "Default"
* LocalReportCustomPathKey
  * This setting defines the path for the .jasper file to be used when generating a custom web report.
  * The path is relative to your project directory, e.g., "Reports/Simple_1.jasper"
* LocalReportOutputFormatKey
  * This setting controls where the report output is HTML or PDF.  Both the standard and custom reports can be output to either format.
  * Valid values are "HTML" or "PDF"

The LocalReportCustomPathKey can be useful when running various types of tests in a CI/CD pipeline.  For example, you may have one
custom format you want to use for a simple terminal feature and a different custom format that you want to use in a test of a web application.
Or you may want to provide more of a summary report format for a group test or playlist, rather than including every single step that was executed.
Or perhaps you may want a custom format that focuses on failures rather than a full report of every step that was executed.  Any such scenario can
be handled with a custom report template.

Note that these reports are designed for a single test. The temporary database which houses the data is deleted when Cycle exits.  For reports that
include historical data or trends, the datastore functionality in Cycle would be more appropriate.  The custom report functionality is provided to give
users an easy way to customize their reports without having to worry about maintaining their own database outside of Cycle for the datastore.

# Examples
A demonstration of creating a new report for Cycle using Jaspersoft studio is available at the link below.
* [Video Demonstration](https://youtu.be/5PFdbZQq9vg)

The .jrxml files for the reports used in that video will be included in your template directory, in the Reports folder.
The queries used in that demonstration are as follows.

## Test Header Information
```sql
select cycle_test_execution.execution_id,
       cycle_test_execution.cycle_user,
       cycle_test_execution.execution_start_ts,
       TRIM(BOTH '"' FROM cycle_test_execution.INVOKER) AS INVOKER,
       cycle_execution_results.name as test_name,
       cycle_execution_results.file_uri as test_file
  from cycle_test_execution
  join cycle_execution_results
    on cycle_execution_results.execution_id = cycle_test_execution.execution_id
   and cycle_execution_results.parent_node_id is null
 where cycle_test_execution.execution_id = $P{execution_id}
```
## Feature Summary Information
```sql
select cycle_execution_results.name,
       cycle_execution_results.node_id,
       cycle_execution_results.status,
       cycle_execution_results.start_time,
       cycle_execution_results.end_time,
       EXTRACT(EPOCH FROM cycle_execution_results.end_time) - EXTRACT(EPOCH FROM cycle_execution_results.start_time) as duration,
       CHAR_LENGTH(cycle_execution_results.node_id) - CHAR_LENGTH(REPLACE(cycle_execution_results.node_id, '.', '')) as depth
  from cycle_test_execution
  join cycle_execution_results
    on cycle_execution_results.execution_id = cycle_test_execution.execution_id
 where cycle_test_execution.execution_id = $P{execution_id}
   and (cycle_execution_results.block_type in ('Scenario:', 'InnerScenario') or cycle_execution_results.node_type = 'Feature')
 order by cycle_execution_results.node_sequence
```
## Feature Detail Information
```sql
select cycle_execution_results.name,
       cycle_execution_results.node_id,
       cycle_execution_results.parent_node_id,
       cycle_execution_results.node_type,
       cycle_execution_results.status,
       cycle_execution_results.start_time,
       cycle_execution_results.end_time,
       EXTRACT(EPOCH FROM cycle_execution_results.end_time) - EXTRACT(EPOCH FROM cycle_execution_results.start_time) as duration,
       CHAR_LENGTH(cycle_execution_results.node_id) - CHAR_LENGTH(REPLACE(cycle_execution_results.node_id, '.', '')) as depth,
       cycle_execution_results.message,
       cycle_execution_results.error_message,
       cycle_terminal_screens.screen,
       cycle_image.id as image_id,
       cycle_image.image
  from cycle_test_execution
  join cycle_execution_results
    on cycle_execution_results.execution_id = cycle_test_execution.execution_id
  left join cycle_terminal_screens
    on cycle_terminal_screens.execution_id = cycle_execution_results.execution_id
   and cycle_terminal_screens.node_id = cycle_execution_results.node_id
  left join cycle_image_results
    on cycle_image_results.execution_id = cycle_execution_results.execution_id
   and cycle_image_results.node_id = cycle_execution_results.node_id
  left join cycle_image
    on cycle_image.id = cycle_image_results.screenshot_image_id
 where cycle_test_execution.execution_id = $P{execution_id}
 order by cycle_execution_results.node_sequence
```
## Group Test Worker Header Information
```sql
select cycle_test_execution.execution_id,
       cycle_execution_results.name as test_name,
       cycle_execution_results.WORKER_NAME,
       CYCLE_EXECUTION_RESULTS.NODE_ID 
  from cycle_test_execution
  join cycle_execution_results
    on cycle_execution_results.execution_id = cycle_test_execution.execution_id
   and cycle_execution_results.parent_node_id is null
 where cycle_test_execution.execution_id = $P{execution_id}
```
### Alternative Group Test Worker Header Information
```sql

WITH recursive nodes(NODE_ID, PARENT_NODE_ID, EXECUTION_ID, group_name) AS 
(
  SELECT NODE_ID,
         PARENT_NODE_ID,
         execution_id,
         name AS group_name,
         NULL AS feature_name,
         NAME,
         NODE_SEQUENCE,
         status,
         NULL AS worker_name
    FROM CYCLE_EXECUTION_RESULTS
   WHERE EXECUTION_ID = $P{execution_id} AND PARENT_NODE_ID = '0-grouptest'
   UNION ALL
  SELECT child.NODE_ID,
         child.PARENT_NODE_ID,
         child.execution_id,
         parent.group_name AS group_name,
         child.name AS feature_name,
         child.NAME,
         child.NODE_SEQUENCE,
         child.status,
         child.worker_name
    FROM CYCLE_EXECUTION_RESULTS as child 
    JOIN nodes as parent
      on parent.execution_id = child.EXECUTION_ID
     AND parent.node_id = child.PARENT_NODE_ID 
   WHERE child.EXECUTION_ID = $P{execution_id} 
     and child.node_type = 'Feature'  
)
SELECT * FROM nodes WHERE worker_name is not null ORDER BY group_name, worker_name;
```
## Group Test Worker Detail Information
```sql
WITH recursive nodes(NODE_ID, PARENT_NODE_ID, EXECUTION_ID) AS 
(
  SELECT NODE_ID, PARENT_NODE_ID, execution_id, NAME, NODE_SEQUENCE
    FROM CYCLE_EXECUTION_RESULTS WHERE EXECUTION_ID = $P{execution_id} AND NODE_ID = $P{node_id}
    UNION ALL
  SELECT child.NODE_ID, child.PARENT_NODE_ID, child.execution_id, child.NAME, CHILD.NODE_SEQUENCE
    FROM CYCLE_EXECUTION_RESULTS as child 
    JOIN nodes as parent on parent.node_id = child.PARENT_NODE_ID 
   WHERE child.EXECUTION_ID = $P{execution_id}
)
SELECT * FROM nodes ORDER BY NODE_SEQUENCE ;
```
