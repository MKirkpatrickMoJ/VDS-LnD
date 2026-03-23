# VDS-L&D Repository

Welcome to a safe space to learn the source control and coding methods that are employed by the VDS team.
The intention of this space is to allow engineers somewhere safe to learn basics on how to create code
(PowerShell) that fits into the space, test scripts (Pester), basics of Terraform and GitHub Actions.

Additionally, there will be some tasks based around GitHub itself to provide exposure to some of the config
and security aspects of the platform.

## Why this is Important

As we transition away from a more GUI-Nerdio based way of working, and more towards an as-Code method,
it is important that there is a consistency in how this is achieved, as well as confidence in being able
to modify and create as required.

## Setup

Each section will provide additional pre-requisite setups, however to begin utilising this repository, the
following must be completed:



## Format

Each folder will have a set of instructions of tasks in increasing complexity. These are numbered in the
suggested order of completion, as some of these will have dependencies on previous steps being completed
before progressing onto the next. This will be:

1. PowerShell - Most engineers are comfortable with PowerShell to some extent. This section is designed
to help think about how we need to use it and give an easier intro to some of the Git elements.
2. Pester - An introduction to testing. Pester a test suite designed for PowerShell, following this
will provide greater understanding of what it is for, how it is used and why it is useful.
3. Terraform - the ultimate infrastructure as code tool - covers almost all things infrastructure.
This segment will provide some setup, creating a basic module, variables and calling these to create (and
then destroy!)
4. Nerdio as Code - a smaller segment as this is ultimately just PowerShell, but provides an opportunity
to get a look at how the code is put together.
5. GitHub Actions - A chance to utilise real DevOps principals such as CI/CD, as well as create a place
to deploy code in an auditable fashion (as in, not locally).

