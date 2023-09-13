## Cycle API Steps Example

This repository contains a small example project showing how to use Cycle's new API testing steps.
It requires Cycle 2.15+.


## Requests

Request specs are located under the [`Requests`](Requests) folder.
Each `.api` file is a request spec for an individual API call.
They all use the [JSONPlaceholder](https://jsonplaceholder.typicode.com/) fake API service.
They are coded as YAML files, but the Cycle app provides a visual interface for editing them.
Testers can configure all parts of an API request: HTTP method, endpoint, body, headers, query parameters, and authentication.
All parts of the request spec may also use variable substitution, such as `${contentType}`.


## Test Cases

The project contains one feature file: [api_test.feature](Test%20Cases/api_test.feature).
It contains scenarios covering [CRUD operations](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) (Create-Read-Update-Delete)
using the API request specs from the `Requests` folder.
These scenarios are basic API tests that follow the standard Request-Retrieve-Ratify pattern.
