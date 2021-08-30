# 1. Allow multiple templates 

Date: 2021-08-30

## Status

Proposed.

## Context

As components become larger (for example, because you are implementing a whole page), it becomes
useful to be able to extract sections of the view to a different file. ActionView has
partials, and ViewComponent lacks a similar mechanism. 

ActionView partials have the problem that their interface is not introspectable. Data
may be passed into the partial via ivars or locals, and it is impossible to know
which without actually opening up the file. Additionally, partials are globally 
invocable, thus making it difficult to detect if a given partial is in use or not,
and who are its users.

An option would be to extract another Component for the extracted section, but that
has the following drawbacks:

1. It creates a new public class.
2. If new component is invoked repeatedly (eg, for a list of items), this creates
   GC pressure by creating lots of intermediate objects.

## Decision

We will allow having multiple templates in the sidecar asset. Each asset will be compiled to
it's own method `call_<template_name>`. In order to allow the compiled method to receive arguments,
the component must define them via a `template_arguments :template_name, :argument1, :argument2`.
This will create required keyword arguments to the `call_<template_name>` method.

## Consequences

This implementation has better performance characteristics over both an extracted component
and ActionView partials, because it avoids creating intermediate objects, and the overhead of
creating bindings and `instance_exec`. 
Having explicit arguments makes the interface explicit.

TODO: The following are consequences of the current approach, but the approach might be extended
to avoid them:

The interface to render a sidecar partial would be a method call, and depart from the usual 
`render(*)` interface used in ActionView.

The generated methods are only invokable via keyword arguments

The generated methods cannot have arguments with default values.

The generated methods are public, and thus could be invoked by a third party.
