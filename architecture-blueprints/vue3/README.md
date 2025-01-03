# FoxyHunter's VUE3 Architecture Blueprint

This architecture is what I've found works best for me personally; by no means should it be seen as "the solution" or "the best way."

It is designed to scale, stay maintainable, and support testing by clearly separating responsibilities. Data management *(repositories)* is distinct from business logic *(services)*, with factories handling the creation and management of these components. The result is a flexible, modular structure that simplifies updates, testing, and scaling, all while maintaining core functionality.

> **WARNING:** This architecture is best suited for larger, more complex Vue projects. For smaller projects, the added structure may introduce unnecessary complexity.

- [FoxyHunter's VUE3 Architecture Blueprint](#foxyhunters-vue3-architecture-blueprint)
  - [Best Practices](#best-practices)
    - [Typscript](#typscript)
    - [Composition API](#composition-api)
    - [Seperation Of Concerns](#seperation-of-concerns)
  - [File Structure](#file-structure)

## Best Practices

### Typscript

[`🔗 Official VUE Docs: "Using Vue with TypeScript"`](https://vuejs.org/guide/typescript/overview)

For larger projects, it's always recommended to use type-safe languages. While they can be frustrating at times, you'll be thankful when they help you avoid mistakes or overlook issues. Install the proper TypeScript linters and avoid bad practices, such as using "any" whenever possible.

### Composition API

[`🔗 Official VUE Docs: "Composition API FAQ -> Why Composition API?"`](https://vuejs.org/guide/extras/composition-api-faq.html#why-composition-api)

The composition API is more efficient, allows for cleaner code with better reuse of functions and logic, it also provides more flexibility in how you structure your code.

It better groups related code blocks together and works best with Type Inference when using TypeScript.

### Seperation Of Concerns

[`🔗 Wikipedia: "Module Pattern"`](https://en.wikipedia.org/wiki/Module_pattern)

Ensuring that each "module", component, or part of code is solely responsible for completing its specific task greatly improves simplicity and readability.

## File Structure

Below is an overview of the desired file/folder structure within the `src/` folder in VUE projects.

- assets/
- components/
- **(new) data/**
- **(new) factories/**
- **(new) repositories/**
- router/
- **(new) services/**
- **(new) types/**
- **(new) util/**
- views/
