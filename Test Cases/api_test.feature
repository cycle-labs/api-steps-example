############################################################
# Copyright © 2019, Tryon Solutions, Inc.
# All rights reserved. Proprietary and confidential.
# This file is subject to the license terms found at
# https://www.cycleautomation.com/end-user-license-agreement/
############################################################
#
# Feature Name: api_test.feature
# Author: Tryon Solutions
# Cycle Version: 2.15.0
#
# Description:
# This simplified executable example Feature is included for
# reference. If executed, it will open notepad, type some text,
# and close notepad.
#
# Usage Instructions:
# Click the "Play" button at the top of the Feature to
# execute this example Feature.
#
# For Additional Information:
# Cycle User Manual: http://www.cycleautomation.com/user-manual/
# Cycle Support: help@cycleautomation.com
############################################################

Feature: API Test

Scenario: Create Data API
Given I assign value "application/json" to unassigned variable "contentType"
And I assign value "My Title" to unassigned variable "title"
When I call api "Requests/create_data.api"
And I verify http response had status code 201
Then I assign http response body to variable "responseBody"
And I echo $responseBody

Scenario: Fetch Data API
Given I assign value "application/json" to unassigned variable "contentType"
And I assign value "My Title" to unassigned variable "title"
When I call api "Requests/get_data.api"
And I verify http response had status code 200
Then I assign http response body to variable "responseBody"
And I echo $responseBody

Scenario: Update Data API
Given I assign value "application/json" to unassigned variable "contentType"
And I assign value "My Updated Title" to unassigned variable "title"
When I call api "Requests/update_data.api"
And I verify http response had status code 200
Then I assign http response body to variable "responseBody"
And I echo $responseBody

Scenario: Delete Data API
Given I assign value "application/json" to unassigned variable "contentType"
When I call api "Requests/delete_data.api"
Then I verify http response had status code 200