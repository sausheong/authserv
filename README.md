# authserv

## Introduction

authserv is a simple REST-based authentication service. Create users in the authserv database using its web interface, then allow other applications to access its user database using a simple REST API.

authserv answers the following questions:

1. Is this a valid user? (authentication)
2. Is the user currently logged in? (validation)
3. Can the user access this resource? (authorization)

REST API features:

* Authentication of a user using email as account ID (returns a session)
* Validation of a session
* Authorization of a user to a resource (resource is any alphanumeric identifier) (NOT IMPLEMENTED YET)
* Check authorization of a user for a resource  (NOT IMPLEMENTED YET)
